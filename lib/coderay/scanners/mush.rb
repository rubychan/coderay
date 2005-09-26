module CodeRay module Scanners
	
	class Mush < Scanner

		register_for :mush
		
		RESERVED_WORDS = [
		]

		IDENT_KIND = Scanner::WordList.new(:ident, :case_ignore).
			add(RESERVED_WORDS, :reserved).
			add(DIRECTIVES, :directive)

		def scan_tokens tokens, options

			state = :initial

			until eos?

				kind = :error
				match = nil

				if state == :initial
					
					if scan(/ \s+ /x)
						kind = :space
						
					elsif scan(%r! \{ \$ [^}]* \}? | \(\* \$ (?: .*? \*\) | .* ) !mx)
						kind = :preprocessor
						
					elsif scan(%r! // [^\n]* | \{ [^}]* \}? | \(\* (?: .*? \*\) | .* ) !mx)
						kind = :comment
						
					elsif scan(/ [-+*\/=<>:;,.@\^|\(\)\[\]]+ /x)
						kind = :operator
						
					elsif match = scan(/ [A-Za-z_][A-Za-z_0-9]* /x)
						kind = IDENT_KIND[match]
						
					elsif match = scan(/ ' ( [^\n']|'' ) (?:'|$) /x)
						tokens << [:open, :char]
						tokens << ["'", :delimiter]
						tokens << [self[1], :content]
						tokens << ["'", :delimiter]
						tokens << [:close, :char]
						next
						
					elsif match = scan(/ ' /x)
						tokens << [:open, :string]
						state = :string
						kind = :delimiter
						
					elsif scan(/ \# (?: \d+ | \$[0-9A-Fa-f]+ ) /x)
						kind = :char
						
					elsif scan(/ \$ [0-9A-Fa-f]+ /x)
						kind = :hex
						
					elsif scan(/ (?: \d+ ) (?![eE]|\.[^.]) /x)
						kind = :integer
						
					elsif scan(/ \d+ (?: \.\d+ (?: [eE][+-]? \d+ )? | [eE][+-]? \d+ ) /x)
						kind = :float

					else
						getch
					end
					
				elsif state == :string
					if scan(/[^\n']+/)
						kind = :content
					elsif scan(/''/)
						kind = :char
					elsif scan(/'/)
						tokens << ["'", :delimiter]
						tokens << [:close, :string]
						state = :initial
						next
					elsif scan(/\n/)
						state = :initial
					else
						raise "else case \' reached; %p not handled." % peek(1), tokens
					end
					
				else
					raise 'else-case reached', tokens
					
				end
				
				match ||= matched
				raise [match, kind], tokens if kind == :error

				tokens << [match, kind]
				
			end
			
			tokens
		end

	end

end end
