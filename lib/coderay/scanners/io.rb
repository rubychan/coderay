module CodeRay module Scanners
  
	#A simple scanner for a simple language: Io
	
	class Io < Scanner

		register_for :io
		
		RESERVED_WORDS = [ 'clone','init', 'method', 'list', 'vector', 'block',  'if','ifTrue','ifFalse','ifTrueIfFalse','then', 'for','loop',
		'reverseForeach','foreach','map','continue','break','while','do','return',
		'self','sender','target','proto','parent','protos']

		PREDEFINED_TYPES = []

		PREDEFINED_CONSTANTS = ['Object', 'Lobby', 
                'TRUE','true','FALSE','false','NULL','null','Null','Nil','nil','YES','NO']

		IDENT_KIND = WordList.new(:ident).
			add(RESERVED_WORDS, :reserved).
			add(PREDEFINED_TYPES, :pre_type).
			add(PREDEFINED_CONSTANTS, :pre_constant)

		ESCAPE = / [rbfnrtv\n\\'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} /x
		UNICODE_ESCAPE =  / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x

		def scan_tokens tokens, options

			state = :initial

			until eos?

				kind = :error
				match = nil

				if state == :initial
					
					if scan(/ \s+ | \\\n /x)
						kind = :space
						
					elsif scan(%r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .* ) !mx)
						kind = :comment

						
					elsif scan(/ [-+*\/\$\@=<>?:;,!&^|()\[\]{}~%]+ | \.(?!\d) /x)
						kind = :operator
						
					elsif match = scan(/ [A-Za-z_][A-Za-z_0-9]* /x)
						kind = IDENT_KIND[match]
						if kind == :ident and check(/:(?!:)/)
							match << scan(/:/)
							kind = :label
						end
						
					elsif match = scan(/L?"/)
						tokens << [:open, :string]
						if match[0] == ?L
							tokens << ['L', :modifier]
							match = '"'
						end
						state = :string
						kind = :delimiter
						
					elsif scan(/#\s*(\w*)/)
						kind = :preprocessor  # FIXME multiline preprocs
						state = :include_expected if self[1] == 'include'
						
					elsif scan(/ L?' (?: [^\'\n\\] | \\ #{ESCAPE} )? '? /ox)
						kind = :char
						
					elsif scan(/0[xX][0-9A-Fa-f]+/)
						kind = :hex
						
					elsif scan(/(?:0[0-7]+)(?![89.eEfF])/)
						kind = :oct
						
					elsif scan(/(?:\d+)(?![.eEfF])/)
						kind = :integer
						
					elsif scan(/\d[fF]?|\d*\.\d+(?:[eE][+-]?\d+)?[fF]?|\d+[eE][+-]?\d+[fF]?/)
						kind = :float

					else
						getch
					end
					
				elsif state == :string
					if scan(/[^\\"]+/)
						kind = :content
					elsif scan(/"/)
						tokens << ['"', :delimiter]
						tokens << [:close, :string]
						state = :initial
						next
					elsif scan(/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox)
						kind = :char
					elsif scan(/ \\ | $ /x)
						kind = :error
						state = :initial
					else
						raise "else case \" reached; %p not handled." % peek(1), tokens
					end
					
				elsif state == :include_expected
					if scan(/<[^>\n]+>?|"[^"\n\\]*(?:\\.[^"\n\\]*)*"?/)
						kind = :include
						state = :initial
						
					elsif match = scan(/\s+/)
						kind = :space
						state = :initial if match.index ?\n
						
					else
						getch
						
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