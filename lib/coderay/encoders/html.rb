module CodeRay
module Encoders

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
		}
		NUMERIZABLE_WRAPPINGS = [:div, :page]
		
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
			if options[:line_numbers] and not NUMERIZABLE_WRAPPINGS.include? options[:wrap]
				warn ':line_numbers wanted, but :wrap is %p' % options[:wrap]
			end
			super
			return if options == @last_options
			@last_options = options

			@HTML_ESCAPE = HTML_ESCAPE.dup
			@HTML_ESCAPE["\t"] = ' ' * options[:tab_width]
			
			@opened = [nil]
			@css = CSS.new

			case options[:css]
			
			when :class
				@css_style = Hash.new do |h, k|
					if k.is_a? Array
						type = k.first
					else
						type = k
					end
					c = ClassOfKind[type]
					if c == :NO_HIGHLIGHT
						h[k] = false
					else
						if options[:debug]
							debug_info = ' title="%p"' % [ k ]
						else
							debug_info = ''
						end
						h[k] = '<span%s class="%s">' % [debug_info, c]
					end
				end
				
			when :style
				@css_style = Hash.new do |h, k|
					if k.is_a? Array
						styles = k.dup
					else
						styles = [k]
					end
					styles.map! { |c| ClassOfKind[c] }
					if styles.first == :NO_HIGHLIGHT
						h[k] = false
					else
						if options[:debug]
							debug_info = ' title="%s"' % [ styles.inspect.gsub(/#{HTML_ESCAPE_PATTERN}/o) { |m| @HTML_ESCAPE[m] } ]
						else
							debug_info = ''
						end
						style = @css[*styles]
						h[k] =
							if style
								'<span%s style="%s">' % [debug_info, style]
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
