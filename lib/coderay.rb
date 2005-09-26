# = CodeRay
#
# CodeRay is a Ruby library for syntax highlighting.
#
# I try to make CodeRay easy to use and intuitive, but at the same time fully featured, complete,
# fast and efficient.
# 
# See README.
# 
# It consists mainly of
# * the main engine: CodeRay, CodeRay::Scanner, CodeRay::Tokens, CodeRay::TokenStream, CodeRay::Encoder
# * the scanners in CodeRay::Scanners
# * the encoders in CodeRay::Encoders
# 
# Here's a fancy graphic to light up this gray docu:
# 
# http://rd.cYcnus.de/coderay/scheme.png
# 
# == Documentation
#
# See CodeRay, Encoders, Scanners, Tokens.
#
# == Usage
#
# Remember you need RubyGems to use CodeRay. Run Ruby with -rubygems option
# if required.
#
# === Highlight Ruby code in a string as html
# 
#   require 'coderay'
#   print CodeRay.scan('puts "Hello, world!"', :ruby).compact.html.page
#
#   # prints something like this:
#   puts <span class="s">&quot;Hello, world!&quot;</span>
# 
# 
# === Highlight C code from a file in a html div
# 
#   require 'coderay'
#   print CodeRay.scan(File.read('ruby.h'), :c).html.div
#   # print CodeRay.scan_file('ruby.h').html.div ## not working yet
# 
# You can include this div in your page. The used CSS styles can be printed with
# 
#   % ruby -rcoderay -e "print CodeRay::Encoders[:html]::CSS"
# 
# === Highlight without typing too much
#
# If you are one of the hasty (or lazy, or extremely curious) people, just run this file:
#
#   % ruby -rubygems coderay.rb
# 
# If the output was to fast for you, try
# 
#   % ruby -rubygems coderay.rb > example.html
#
# and look at the file it created.
# 
module CodeRay
	
	Version = '0.4.2'
	
	require 'coderay/tokens'
	require 'coderay/scanner'
	require 'coderay/encoder'


	class << self

		# Scans the given +code+ (a String) with the Scanner for +lang+.
		# 
		# This is a simple way to use CodeRay. Example:
		#  require 'coderay'
		#  page = CodeRay.scan("puts 'Hello, world!'", :ruby).html
		#
		# See also demo/demo_simple.
		def scan code, lang, options = {}, &block
			scanner = Scanners[lang].new code, options, &block
			scanner.tokenize
		end

		# Scans +filename+ (a path to a code file) with the Scanner for +lang+.
		# 
		# If +lang+ is :auto or omitted, the CodeRay::FileType module is used to
		# determine it. If it cannot find out what type it is, it uses CodeRay::Scanners::Plaintext.
		#
		# Calls CodeRay.scan.
		# 
		# Example:
		#  require 'coderay'
		#  page = CodeRay.scan_file('some_c_code.c').html
		def scan_file filename, lang = :auto, options = {}, &block
			file = IO.read filename
			if lang == :auto
				require 'coderay/helpers/filetype'
				lang = FileType.fetch filename, :plaintext, true
			end
			scan file, lang, options = {}, &block
		end

		# Scan the +code+ (a string) with the scanner for +lang+.
		# 
		# Calls scan.
		# 
		# See CodeRay.scan.
		def scan_stream code, lang, options = {}, &block
			options[:stream] = true
			scan code, lang, options, &block
		end

		# Encode +code+ with the Encoder for +format+ and the Scanner for +lang+.
		# +options+ will be passed to the Encoder.
		#
		# See CodeRay::Encoder.encode_stream
		def encode_stream code, lang, format, options = {}
			encoder(format, options).encode_stream code, lang, options
		end

		def encode code, lang, format, options = {}
			encoder(format, options).encode code, lang, options
		end

		# Finds the Encoder class for +format+ and creates an instance, passing
		# +options+ to it.
		# 
		# Example:
		#  require 'coderay'
		#  token_count = CodeRay.encoder(:count).encodea("puts 17 + 4\n", :ruby).to_i  #-> 8
		#  require 'coderay'
		#  
		#  stats = CodeRay.encoder(:statistic)
		#  stats.encode("puts 17 + 4\n", :ruby)
		#  
		#  puts '%d out of %d tokens have the kind :integer.' % [
		#  	stats.type_stats[:integer].count,
		#  	stats.real_token_count
		#  ]
		#  #-> 2 out of 4 tokens have the kind :integer.
		def encoder format, options = {}
			Encoders[format].new options
		end

	end

	# This Exception is raised when you try to stream with something that is not
	# capable of streaming.
	class NotStreamableError < Exception
		def initialize obj
			@obj = obj
		end

		def to_s
			'%s is not Streamable!' % @obj.class
		end
	end
	
	# A dummy module that is included by subclasses of CodeRay::Scanner an CodeRay::Encoder
	# to show that they are able to handle streams.
	module Streamable
	end
	
end

# Run a test script.
if $0 == __FILE__
	$stderr.print 'Press key to print demo.'; gets
	code = File.read($0)[/module CodeRay.*/m]
	print CodeRay.scan(code, :ruby).html
end
