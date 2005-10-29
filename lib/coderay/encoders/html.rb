module CodeRay
module Encoders

	# = HTML Encoder
	#
	# This is CodeRay's most important highlighter:
	# It provides save, fast XHTML generation and CSS support.
	#
	# == Usage
	#
	#  require 'coderay'
	#  puts CodeRay.scan('Some /code/', :ruby).html  #-> a HTML page
	#  puts CodeRay.scan('Some /code/', :ruby).html(:wrap => :span) #-> <span class="CodeRay"><span class="co">Some</span> /code/</span>
	#  puts CodeRay.scan('Some /code/', :ruby).span  #-> the same
	#  
	#  puts CodeRay.scan('Some code', :ruby).html(
	#    :wrap => nil,
	#    :line_numbers => :inline,
	#    :css => :style
	#  )
	#  #-> <span class="no">1</span>  <span style="color:#036; font-weight:bold;">Some</span> code
	#
	# == Options
	#
	# :tab_width::        Convert \t characters to +n+ spaces (a number.)
	#                     Default: 8
	# :css::              How to include the styles; can be :class or :style.
	#                     Default: :class
	# :wrap::             Wrap in :page, :div, :span or nil.
	#                     Default: :page
	#                     You can also use Encoders::Div and Encoders::Span.
	# :line_numbers::     Include line numbers in :table, :inline or nil (no line numbers)
	#                     Default: nil
	# :line_number_start: Where to start with line number counting.
	#                     Default: 1
	# :bold_every::       Make every +n+-th number appear bold.
	#                     Default: 10
	# :hint::             Include some information into the output using the title attribute.
	#                     Can be :info (show token type on mouse-over) or :debug.
	#                     Default: false
	class HTML < Encoder

		include Streamable
		register_for :html

		FILE_EXTENSION = 'html'

		DEFAULT_OPTIONS = {
			:tab_width => 8,

			:level => :xhtml,
			:css => :class,

			:wrap => :page,

			:line_numbers => nil,
			:line_number_start => 1,
			:bold_every => 10,

			:hint => false,
		}
		
		require 'coderay/encoders/helpers/html_helper'
		require 'coderay/encoders/helpers/html_output'
		require 'coderay/encoders/helpers/html_css'

		def initialize(*)
			super
			@last_options = nil
		end

	protected
		
		HTML_ESCAPE = {  #:nodoc:
			'&' => '&amp;',
			'"' => '&quot;',
			'>' => '&gt;',
			'<' => '&lt;',
		}

		# This is to prevent illegal HTML.
		# Strange chars should still be avoided in codes.
		evil_chars = Array(0x00...0x20) - [?n, ?t]
		evil_chars.each { |i| HTML_ESCAPE[i.chr] = ' ' }
		ansi_chars = Array(0x7f..0xff)
		ansi_chars.each { |i| HTML_ESCAPE[i.chr] = '&#%d;' % i }
		# \x9 (\t) and \xA (\n) not included
		HTML_ESCAPE_PATTERN = /[&"><\0-\x8\xB-\x1f\x7f-\xff]/

		def setup options
			super
			return if options == @last_options
			@last_options = options

			@HTML_ESCAPE = HTML_ESCAPE.dup
			@HTML_ESCAPE["\t"] = ' ' * options[:tab_width]
			
			@opened = [nil]
			@css = CSS.new

			hint = options[:hint]
			raise ArgumentError if hint and not [:debug, :info].include? hint

			case options[:css]
			
			when :class
				@css_style = Hash.new do |h, k|
					if k.is_a? Array
						type = k.first
					else
						type = k
					end
					c = ClassOfKind[type]
					if c == :NO_HIGHLIGHT and not hint
						h[k] = false
					else
						title = if hint
							if hint == :debug
								' title="%p"' % [ k ]
							elsif hint == :info and k.size == 1
								" title=\"#{type.to_s.gsub(/_/, " ").capitalize}\""
							end
						else
							''
						end
						h[k] = '<span%s class="%s">' % [title, c]
					end
				end
				
			when :style
				@css_style = Hash.new do |h, k|
					if k.is_a? Array
						styles = k.dup
					else
						styles = [k]
					end
					type = styles.first
					styles.map! { |c| ClassOfKind[c] }
					if styles.first == :NO_HIGHLIGHT and not hint
						h[k] = false
					else
						title = if hint
							if hint == :debug
								' title="%p"' % [ styles ]
							elsif hint == :info and styles.size == 1
								" title=\"#{type.to_s.gsub(/_/, " ").capitalize}\""
							end
						else
							''
						end
						style = @css[*styles]
						h[k] =
							if style
								'<span%s style="%s">' % [title, style]
							else
								false
							end
					end
				end
				
			else
				raise "Unknown value %p for :css." % options[:css]
				
			end
		end

		def finish options
			not_needed = @opened.shift
			@out << '</span>' * @opened.size

			@out.extend Output
			@out.numerize! options[:line_numbers], options # if options[:line_numbers]
			@out.wrap! options[:wrap] # if options[:wrap]

			#require 'pp'
			#pp @css_style, @css_style.size

			super
		end

		def token text, type
			if text.is_a? String
				if text =~ /#{HTML_ESCAPE_PATTERN}/o
					text = text.gsub(/#{HTML_ESCAPE_PATTERN}/o) { |m| @HTML_ESCAPE[m] }
				end
				@opened[0] = type
				style = @css_style[@opened]
				if style
					@out << style << text << '</span>'
				else
					@out << text
				end
			else
				case text
				when :open
					@opened[0] = type
					@out << @css_style[@opened]
					@opened << type
				when :close
					unless @opened.empty?
						raise 'Not Token to be closed.' unless @opened.size > 1
						@out << '</span>'
						@opened.pop
					end
				when nil
					raise 'Token with nil as text was given: %p' % [[text, type]]
				else
					raise 'unknown token kind: %p' % text
				end
			end
		end
		
	end

end
end
