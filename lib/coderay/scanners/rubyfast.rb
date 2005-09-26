module CodeRay module Scanners

	class Ruby < Scanner

		register_for :rubyfast

		RESERVED_WORDS = [
			'and', 'def', 'end', 'in', 'or', 'unless', 'begin',
			'defined?', 'ensure', 'module', 'redo', 'super', 'until',
			'BEGIN', 'break', 'do', 'next', 'rescue', 'then',
			'when', 'END', 'case', 'else', 'for', 'retry',
			'while', 'alias', 'class', 'elsif', 'if', 'not', 'return',
			'undef', 'yield',
		]

		DEF_KEYWORDS = ['def']
		MODULE_KEYWORDS = ['class', 'module']
		DEF_NEW_STATE = WordList.new(:initial).
			add(DEF_KEYWORDS, :def_expected).
			add(MODULE_KEYWORDS, :module_expected)

		WORDS_ALLOWING_REGEXP = [
			'and', 'or', 'not', 'while', 'until', 'unless', 'if', 'elsif', 'when'
		]
		REGEXP_ALLOWED = WordList.new(false).
			add(WORDS_ALLOWING_REGEXP, :set)
		
		PREDEFINED_CONSTANTS = [
			'nil', 'true', 'false', 'self',
			'DATA', 'ARGV', 'ARGF', '__FILE__', '__LINE__',
		]

		IDENT_KIND = WordList.new(:ident).
			add(RESERVED_WORDS, :reserved).
			add(PREDEFINED_CONSTANTS, :pre_constant)

		IDENT = /[a-zA-Z_][a-zA-Z_0-9]*/

		METHOD_NAME = / #{IDENT} [?!]? /xo
		METHOD_NAME_EX = /
		#{IDENT}[?!=]?  # common methods: split, foo=, empty?, gsub!
		| \*\*?         # multiplication and power
		| [-+~]@?       # plus, minus
		| [\/%&|^`]     # division, modulo or format strings, &and, |or, ^xor, `system`
		| \[\]=?        # array getter and setter
		| <=?>? | >=?   # comparison, rocket operator
		| << | >>       # append or shift left, shift right
		| ===?          # simple equality and case equality
		/ox
		GLOBAL_VARIABLE = / \$ (?: #{IDENT} | [1-9] | 0[a-zA-Z_0-9]* | [~&+`'=\/,;_.<>!@$?*":\\] | -[a-zA-Z_0-9] ) /ox

		DOUBLEQ = / " [^"\#\\]* (?: (?: \#\{.*?\} | \#(?:$")? | \\. ) [^"\#\\]* )* "? /mox
		SINGLEQ = / ' [^'\\]*   (?:                             \\.   [^'\\]*   )* '? /mox
		STRING  = / #{SINGLEQ} | #{DOUBLEQ} /ox

		SHELL   = / ` [^`\#\\]* (?: (?: \#\{.*?\} | \#(?:$`)? | \\. ) [^`\#\\]* )* `? /mox
		REGEXP =%r! / [^/\#\\]* (?: (?: \#\{.*?\} | \#(?:$/)? | \\. ) [^/\#\\]* )* /? !mox
		
		DECIMAL = /\d+(?:_\d+)*/  # doesn't recognize 09 as octal error
		OCTAL = /0_?[0-7]+(?:_[0-7]+)*/
		HEXADECIMAL = /0x[0-9A-Fa-f]+(?:_[0-9A-Fa-f]+)*/
		BINARY = /0b[01]+(?:_[01]+)*/

		EXPONENT = / [eE] [+-]? #{DECIMAL} /ox
		FLOAT = / #{DECIMAL} (?: #{EXPONENT} | \. #{DECIMAL} #{EXPONENT}? ) /
		INTEGER = /#{OCTAL}|#{HEXADECIMAL}|#{BINARY}|#{DECIMAL}/

		ESCAPE_STRING = /
			% (?!\s)
			(?:
				[qsw]
				(?:
					\( [^\)\\]* (?: \\. [^\)\\]* )* \)?
				|
					\[ [^\]\\]* (?: \\. [^\]\\]* )* \]?
				|
					\{ [^\}\\]* (?: \\. [^\}\\]* )* \}?
				|
					\< [^\>\\]* (?: \\. [^\>\\]* )* \>?
				|
					\\ [^\\  ]*                     \\?
				|
					( [^a-zA-Z0-9] )  # $1
					(?:(?!\1)[^\\])* (?: \\. (?:(?!\1)[^\#\\])* )* \1?
				)
			|
				[QrxWr]?
				(?:
					\( [^\)\#\\]* (?: (?:\#\{.*?\}|\#|\\.) [^\)\#\\]* )* \)?
				|
					\[ [^\]\#\\]* (?: (?:\#\{.*?\}|\#|\\.) [^\]\#\\]* )* \]?
				|
					\{ [^\}\#\\]* (?: (?:\#\{.*?\}|\#|\\.) [^\}\#\\]* )* \}?
				|
					\< [^\>\#\\]* (?: (?:\#\{.*?\}|\#|\\.) [^\>\#\\]* )* \>?
				|
					\# [^\#  \\]* (?:                 \\.  [^\#  \\]* )* \#?
				|
					\\ [^\\\#  ]* (?: (?:\#\{.*?\}|\#    ) [^\\\#  ]* )* \\?
				|
					( [^a-zA-Z0-9] )  # $2
					(?:(?!\2)[^\#\\])* (?: (?:\#\{.*?\}|\#|\\.) (?:(?!\2)[^\#\\])* )* \2?
				)
			)
		/mox
		
		SYMBOL = /
			:
			(?:
			  #{GLOBAL_VARIABLE}
			|	@@?#{IDENT}
			| #{METHOD_NAME_EX}
			| #{STRING}
		)/ox

		HEREDOC = /
			<< (?! [\dc] )
			(?: [^\n]*? << )?
			(?:
				([a-zA-Z_0-9]+) 
					(?: .*? ^\1$ | .* )
			|
				-([a-zA-Z_0-9]+)
					(?: .*? ^\s*\2$ | .* )
			|
				(["\'`]) (.*?) \3
					(?: .*? ^\4$ | .* )
			| 
				- (["\'`]) (.*?) \5
					(?: .*? ^\s*\6$ | .* )
			)
		/mx

		RDOC = /
			=begin (?!\S) [^\n]* \n?
			(?:
				(?! =end (?!\S) )
				[^\n]* \n?
			)*
			(?:
				=end (?!\S) [^\n]*
			)?
		/mx

		DATA = /
			__END__\n
			(?:
				(?=\#CODE)
			|
				.*
			)
		/

	private
		def scan_tokens tokens, options
			
			state = :initial
			regexp_allowed = true
			last_token_dot = false

			until eos?
				match = nil
				kind = :error

				if scan(/\s+/)  # in every state
					kind = :space
					regexp_allowed = :set if regexp_allowed or matched.index(?\n)  # delayed flag setting

				elsif scan(/ \#[^\n]* /x)  # in every state
					kind = :comment
					regexp_allowed = :set if regexp_allowed

				elsif state == :initial
					# IDENTIFIERS, KEYWORDS
					if scan(GLOBAL_VARIABLE)
						kind = :global_variable
					elsif scan(/ @@ #{IDENT} /ox)
						kind = :class_variable
					elsif scan(/ @ #{IDENT} /ox)
						kind = :instance_variable
					elsif scan(/ #{DATA} | #{RDOC} /ox)
						kind = :comment
					elsif scan(METHOD_NAME)
						match = matched
						if last_token_dot
							kind =
								if match[/^[A-Z]/]
									:constant
								else
									:ident
								end
						else
							kind = IDENT_KIND[match]
							if kind == :ident and match[/^[A-Z]/]
								kind = :constant
							elsif kind == :reserved
								state = DEF_NEW_STATE[match]
								regexp_allowed = REGEXP_ALLOWED[match]
							end
						end
						
					elsif scan(STRING)
						kind = :string
					elsif scan(SHELL)
						kind = :shell
					elsif scan(HEREDOC)
						kind = :string
					elsif check(/\//) and regexp_allowed
						scan(REGEXP)
						kind = :regexp
					elsif scan(ESCAPE_STRING)
						match = matched
						kind = 
							case match[0]
							when ?s
								:symbol
							when ?r
								:regexp
							when ?x
								:shell
							else
								:string
							end

					elsif scan(/:(?:#{GLOBAL_VARIABLE}|#{METHOD_NAME_EX}|#{STRING})/ox)
						kind = :symbol
					elsif scan(/
						\? (?:
							[^\s\\]
						| 
							\\ (?:M-\\C-|C-\\M-|M-\\c|c\\M-|c|C-|M-))? (?: \\ (?: . | [0-7]{3} | x[0-9A-Fa-f][0-9A-Fa-f] )
						)
					/mx)
						kind = :integer
						
					elsif scan(/ [-+*\/%=<>;,|&!()\[\]{}~?] | \.\.?\.? | ::? /x)
						kind = :operator
						match = matched
						regexp_allowed = :set if match[-1,1] =~ /[~=!<>|&^,\(\[+\-\/\*%]\z/
						last_token_dot = :set if match == '.' or match == '::'
					elsif scan(FLOAT)
						kind = :float
					elsif scan(INTEGER)
						kind = :integer
					else
						getch
					end
					
				elsif state == :def_expected
					if scan(/ (?:#{IDENT}::)* (?:#{IDENT}\.)? #{METHOD_NAME_EX} /ox)
						kind = :method
					else
						getch
					end
					state = :initial
					
				elsif state == :module_expected
					if scan(/<</)
						kind = :operator
					else
						if scan(/ (?:#{IDENT}::)* #{IDENT} /ox)
							kind = :method
						else
							getch
						end
						state = :initial
					end
					
				end
				
				text = match || matched

				if kind == :regexp and not eos?
					text << scan(/[eimnosux]*/)
				end
				
				regexp_allowed = (regexp_allowed == :set)  # delayed flag setting
				last_token_dot = last_token_dot == :set

				tokens << [text, kind]
			end

			tokens
		end
	end

end end
