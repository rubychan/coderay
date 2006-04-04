#require 'coderay/common_patterns'

module CodeRay module Scanners

	# HTML Scanner
	class HTML < Scanner

		include Streamable
		register_for :html

		ATTR_NAME = /[\w.:-]+/
		ATTR_VALUE_UNQUOTED = ATTR_NAME
		TAG_END = /\/?>/
		HEX = /[0-9a-fA-F]/
		ENTITY = /
			&
			(?:
				\w+
			|
				\#
				(?:
					\d+
				|
					x#{HEX}+
				)
			)
			;
		/ox

	private
		def scan_tokens tokens, options
			
			state = :initial
			
			until eos?
				
				kind = :error
				match = nil

				if scan(/\s+/m)
					kind = :space
					
				else
					
					case state
						
					when :initial
						if scan(/<!--.*?-->/m)
							kind = :comment
						elsif scan(/<!DOCTYPE.*?>/m)
							kind = :preprocessor
						elsif scan(/<\?xml.*?\?>/m)
							kind = :preprocessor
						elsif scan(/<\?.*?\?>|<%.*?%>/m)
							kind = :comment
						elsif scan(/<\/[-\w_.:]*>/m)
							kind = :tag
						elsif match = scan(/<[-\w_.:]*/m)
							kind = :tag
							if match?(/>/)
								match << getch
							else
								state = :attribute
							end
						elsif scan(/[^<>&]+/)
							kind = :plain
						elsif scan(/#{ENTITY}/ox)
							kind = :char
						elsif scan(/>/)
							kind = :error
						else
							raise_inspect '[BUG] else-case reached with state %p' % [state], tokens
						end
						
					when :attribute
						if scan(/#{TAG_END}/)
							kind = :tag
							state = :initial
						elsif scan(/#{ATTR_NAME}/o)
							kind = :attribute_name
							state = :attribute_equal
						end

					when :attribute_equal
						if scan(/=/)
							kind = :operator
							state = :attribute_value
						elsif scan(/#{ATTR_NAME}/o)
							kind = :attribute_name
						elsif scan(/#{TAG_END}/o)
							kind = :tag
							state = :initial
						elsif scan(/./)
							state = :attribute
						end
						
					when :attribute_value
						if scan(/#{ATTR_VALUE_UNQUOTED}/o)
							kind = :attribute_value
							state = :attribute
						elsif scan(/"/)
							tokens << [:open, :string]
							state = :attribute_value_string
							kind = :delimiter
						elsif scan(/#{TAG_END}/o)
							kind = :tag
							state = :initial
						end

					when :attribute_value_string
						if scan(/[^"&\n]+/)
							kind = :content
						elsif scan(/"/)
							tokens << ['"', :delimiter]
							tokens << [:close, :string]
							state = :attribute
							next
						elsif scan(/#{ENTITY}/ox)
							kind = :char
						elsif match(/\n/)
							tokens << [:close, :string]
							state = :attribute
							next
						end

					else
						raise_inspect 'Unknown state: %p' % [state], tokens

					end

				end

				match ||= matched
				if $DEBUG and (not kind or kind == :error)
					raise_inspect 'Error token %p in line %d' %
					[[match, kind], line], tokens
				end
				raise_inspect 'Empty token', tokens unless match

				tokens << [match, kind]
			end

			tokens
		end

	end

end end
