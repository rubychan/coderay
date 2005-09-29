
# = PluginHost
#
# $Id$
#
# A simple subclass plugin system.
# 
#	Example:		
#		class Generators < PluginHost
#			plugin_path 'app/generators'
#		end
#		
#	  class Generator
#	  	extend Plugin
#	  	PLUGIN_HOST = Generators
#	  end
#   
#	  class FancyGenerator < Generator
#	  	register_for :fancy
#	  end
#
#	  Generators[:fancy]  #-> FancyGenerator
#	  # or
#	  require_plugin 'Generators/fancy'
module PluginHost

	# Raised if Encoders::[] fails because:
	# * a file could not be found
	# * the requested Encoder is not registered
	PluginNotFound = Class.new Exception

	PLUGIN_HOSTS = []
	PLUGIN_HOSTS_BY_ID = {}  # dummy hash

	class << self

		def extended mod
			PLUGIN_HOSTS << mod
		end

		def included mod
			warn "#{name} should not be included. Use extend."
		end

		# Find the PluginHost for host_id.
		def host_by_id host_id
			unless PLUGIN_HOSTS_BY_ID.default_proc
				ph = Hash.new do |h, _host_id|
					for host in PLUGIN_HOSTS
						h[host.host_id] = host
					end
					h.fetch _host_id, nil
				end				
				PLUGIN_HOSTS_BY_ID.replace ph
			end
			PLUGIN_HOSTS_BY_ID[host_id]
		end

	end
	
		def plugin_host_id host_id
			if host_id.is_a? String
				raise ArgumentError,
					"String or Symbol expected, but #{lang.class} given."
			end
			
		end

		# The path where the plugins can be found.
		def plugin_path *args
			unless args.empty?
				@plugin_path = File.join(*args)
			end
			@plugin_path
		end

		# The host's ID.
		#
		# If PLUGIN_HOST_ID is not set, it is simply the class name.
		def host_id
			if self.const_defined? :PLUGIN_HOST_ID
				self::PLUGIN_HOST_ID
			else
				name
			end
		end

		def create_plugin_hash
			@plugin_hash =
				Hash.new do |h, plugin_id|
					id = validate_id(plugin_id)
					path = path_to id
					begin
						puts 'Loading plugin: ' + path if $DEBUG
						require path
					rescue LoadError
						raise PluginNotFound, "#{path} not found."
					else
						# Plugin should have registered by now
						unless h.has_key? id
							raise PluginNotFound,
								"No #{self.name} plugin for #{id} found in #{path}."
						end
					end
					h[id]
				end
		end

		def plugin_hash
			@plugin_hash ||= create_plugin_hash
		end


		# Every plugin must register itself for one or more
		# +ids+ by calling register_for, which calls this method.
		#
		# See Plugin#register_for.
		def register plugin, *ids
			for id in ids
				unless id.is_a? Symbol
					raise ArgumentError,
						"id must be a Symbol, but it was a #{id.class}" 
				end
				plugin_hash[validate_id(id)] = plugin
			end
		end


		# Returns an array of all .rb files in the plugin path.
		# 
		# The extension .rb is not included.
		def all_plugin_names
			Dir[path_to('*')].map do |file|
				File.basename file, '.rb'
			end
		end

		# Loads all plugins using all_plugin_names and load.
		def load_all
			for plugin in all_plugin_names
				load_plugin plugin
			end
		end


		# Returns the Plugin for +id+.
		# 
		# Example:
		#  yaml_plugin = MyPluginHost[:yaml]
		def [] id, *args, &blk
			plugin_hash.[] validate_id(id), *args, &blk
		end

		# Alias for +[]+.
		alias load_plugin []

		# Returns the Plugin for +id+.
		# Use it like Hash#fetch.
		# 
		# Example:
		#  yaml_plugin = MyPluginHost[:yaml, :default]
		def fetch id, *args, &blk
			plugin_hash.fetch validate_id(id), *args, &blk
		end

		# Returns the path to the encoder for format.
		def path_to plugin_id
			File.join plugin_path, "#{plugin_id}.rb"
		end

		# Converts +id+ to a downcase Symbol if it is a String,
		# or returns +id+ if it already is a Symbol.
		#
		# Raises +ArgumentError+ for all other objects, or if the
		# given String includes non-alphanumeric characters (\W).
		def validate_id id
			if id.is_a? Symbol
				id
			elsif id.is_a? String
				if id[/\w+/] == id
					id.downcase.to_sym
				else
					raise ArgumentError, "Invalid id: '#{id}' given."
				end
			else
				raise ArgumentError,
					"String or Symbol expected, but #{id.class} given."
			end
		end

	#end


end


# = Plugin
# 
#	Plugins have to include this module.
#
#	IMPORTANT: use extend for this module.
#
#	Example: see PluginHost.
module Plugin

	def included mod
		warn "#{name} should not be included. Use extend."
	end

	# Register this class for the given langs.
	# Example:
	#   class MyPlugin < PluginHost::BaseClass
	#     register_for :my_id
	#     ...
	#   end
	#
	# See PluginHost.register.
	def register_for *ids
		plugin_host.register self, *ids
	end

	# The host for this Plugin class.
	def plugin_host host = nil
		if host and not host.is_a? PluginHost
			raise ArgumentError,
				"PluginHost expected, but #{host.class} given."
		end
		self.const_set :PLUGIN_HOST, host if host
		self::PLUGIN_HOST
	end

end


# Convenience method for plugin loading.
# The syntax used is:
#
#  require_plugin '<Host ID>/<Plugin ID>'
# 
# Returns the loaded plugin.
def require_plugin path
	host, plugin_id = path.split '/', 2
	PluginHost.host_by_id(host).load_plugin plugin_id
end


if $0 == __FILE__
	$VERBOSE = $DEBUG = true
	eval DATA.read, nil, $0, __LINE__+4
end

__END__

require 'test/unit'

class TC_PLUGINS < Test::Unit::TestCase

	class Generators
		extend PluginHost
		plugin_path '.'
	end

	class Generator
		extend Plugin
		plugin_host Generators
	end

	class FancyGenerator < Generator
		register_for :plugin_host
	end

	def test_plugin
		assert_nothing_raised do
			Generators[:plugin_host]
		end	
		assert_equal FancyGenerator, Generators[:plugin_host]
	end
	
	def test_require
		assert_nothing_raised do
			require_plugin('TC_PLUGINS::Generators/plugin_host')
		end
		assert_equal FancyGenerator,
			require_plugin('TC_PLUGINS::Generators/plugin_host')
	end

end
