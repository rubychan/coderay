module CodeRay module Scanners

	class Ruby

		RESERVED_WORDS = %w[
			and def end in or unless begin
			defined? ensure module redo super until
			BEGIN break do next rescue then
			when END case else for retry
			while alias class elsif if not return
			undef yield
		]

		DEF_KEYWORDS = %w[ def ]
		MODULE_KEYWORDS = %w[class module]
		DEF_NEW_STATE = WordList.new(:initial).
			add(DEF_KEYWORDS, :def_expected).
			add(MODULE_KEYWORDS, :module_expected)

		IDENTS_ALLOWING_REGEXP = %w[
			and or not while until unless if then elsif when sub sub! gsub gsub! scan slice slice! split
		]
		REGEXP_ALLOWED = WordList.new(false).
			add(IDENTS_ALLOWING_REGEXP, :set)
		
		PREDEFINED_CONSTANTS = %w[
			nil true false self
			DATA ARGV ARGF __FILE__ __LINE__
		]

		IDENT_KIND = WordList.new(:ident).
			add(RESERVED_WORDS, :reserved).
			add(PREDEFINED_CONSTANTS, :pre_constant)

#		IDENT = /[a-zA-Z_][a-zA-Z_0-9]*/
		IDENT = /[a-z_][\w_]*/i

		METHOD_NAME = / #{IDENT} [?!]? /ox
		METHOD_NAME_EX = /
			#{IDENT}[?!=]?  # common methods: split, foo=, empty?, gsub!
			| \*\*?         # multiplication and power
			| [-+]@?        # plus, minus
			| [\/%&|^`~]    # division, modulo or format strings, &and, |or, ^xor, `system`, tilde
			| \[\]=?        # array getter and setter
			| << | >>       # append or shift left, shift right
			| <=?>? | >=?   # comparison, rocket operator
			| ===?          # simple equality and case equality
		/ox
		INSTANCE_VARIABLE = / @ #{IDENT} /ox
		CLASS_VARIABLE = / @@ #{IDENT} /ox
		OBJECT_VARIABLE = / @@? #{IDENT} /ox
		GLOBAL_VARIABLE = / \$ (?: #{IDENT} | [1-9] | 0[a-zA-Z_0-9]* | [~&+`'=\/,;_.<>!@$?*":\\] | -[a-zA-Z_0-9] ) /ox
		PREFIX_VARIABLE = / #{GLOBAL_VARIABLE} |#{OBJECT_VARIABLE} /ox
		VARIABLE = / @?@? #{IDENT} | #{GLOBAL_VARIABLE} /ox

		QUOTE_TO_TYPE = {
			'`' => :shell,
			'/'=> :regexp,
		}
		QUOTE_TO_TYPE.default = :string
		
		REGEXP_MODIFIERS = /[mixounse]*/
		REGEXP_SYMBOLS = /
			[|?*+?(){}\[\].^$]
		/x

		DECIMAL = /\d+(?:_\d+)*/  # doesn't recognize 09 as octal error
		OCTAL = /0_?[0-7]+(?:_[0-7]+)*/
		HEXADECIMAL = /0x[0-9A-Fa-f]+(?:_[0-9A-Fa-f]+)*/
		BINARY = /0b[01]+(?:_[01]+)*/

		EXPONENT = / [eE] [+-]? #{DECIMAL} /ox
		FLOAT_OR_INT = / #{DECIMAL} (?: #{EXPONENT} | \. #{DECIMAL} #{EXPONENT}? )? /ox
		FLOAT = / #{DECIMAL} (?: #{EXPONENT} | \. #{DECIMAL} #{EXPONENT}? ) /ox
		NUMERIC = / #{OCTAL} | #{HEXADECIMAL} | #{BINARY} | #{FLOAT_OR_INT} /ox

		SYMBOL = /
			:
			(?:
				#{METHOD_NAME_EX}
			| #{PREFIX_VARIABLE}
			| ['"]
			)
		/ox

		# TODO investigste \M, \c and \C escape sequences
		# (?: M-\\C-|C-\\M-|M-\\c|c\\M-|c|C-|M-)? (?: \\ (?: [0-7]{3} | x[0-9A-Fa-f]{2} | . ) )
		# assert_equal(225, ?\M-a)
		# assert_equal(129, ?\M-\C-a)
		ESCAPE = /
				[abefnrstv]
			| M-\\C-|C-\\M-|M-\\c|c\\M-|c|C-|M-
			|	[0-7]{1,3}
			| x[0-9A-Fa-f]{1,2}
			| .
		/mx

		CHARACTER = /
			\?
			(?:
				[^\s\\]
			| \\ #{ESCAPE}
			)
		/mx

		# NOTE: This is not completel correct, but
		# nobody needs heredoc delimiters ending with \n.
		HEREDOC_OPEN = /
			<< (-)?              # $1 = float
			(?:
				( [A-Za-z_0-9]+ )  # $2 = delim
			|
				( ["'`] )          # $3 = quote, type
				( [^\n]*? ) \3     # $4 = delim
			)
		/mx

		RDOC = /
			=begin (?!\S)
			.*?
			(?: \Z | ^=end (?!\S) [^\n]* )
		/mx

		DATA = /
			__END__$
			.*?
			(?: \Z | (?=^\#CODE) )
		/mx

		RDOC_DATA_START = / ^=begin (?!\S) | ^__END__$ /x

		FANCY_START = / % ( [qQwWxsr] | (?![\w\s=]) ) (.) /mox

		FancyStringType = {
			'q' => [:string, false],
			'Q' => [:string, true],
			'r' => [:regexp, true],
			's' => [:symbol, false],
			'x' => [:shell, true],
			'w' => [:string, :word],
			'W' => [:string, :word],
		}
		FancyStringType['w'] = FancyStringType['q']
		FancyStringType['W'] = FancyStringType[''] = FancyStringType['Q']
			
		class StringState < Struct.new :type, :interpreted, :delim, :heredoc,
			:paren, :paren_depth, :pattern
			
			CLOSING_PAREN = Hash[ *%w[
				( )
				[ ]
				< >
				{ }
			] ]
			
			CLOSING_PAREN.values.each { |o| o.freeze }  # debug, if I try to change it with <<
			OPENING_PAREN = CLOSING_PAREN.invert

			STRING_PATTERN = Hash.new { |h, k|
				delim, interpreted = *k
				delim_pattern = Regexp.escape(delim.dup)
				if starter = OPENING_PAREN[delim]
					delim_pattern << Regexp.escape(starter)
				end

				
				special_escapes = 
					case interpreted
					when :regexp_symbols
						'| ' + REGEXP_SYMBOLS.source
					when :words
						'| \s'
					end

				h[k] =
					if interpreted and not delim == '#'
						/ (?= [#{delim_pattern}\\] | \# [{$@] #{special_escapes} ) /mx
					else
						/ (?= [#{delim_pattern}\\] #{special_escapes} ) /mx
					end
			}

			HEREDOC_PATTERN = Hash.new { |h, k|
				delim, interpreted, indented = *k
				delim_pattern = Regexp.escape(delim.dup)
				delim_pattern = / \n #{ '(?>[\ \t]*)' if indented } #{ Regexp.new delim_pattern } $ /x
				h[k] =
					if interpreted
						/ (?= #{delim_pattern}() | \\ | \# [{$@] ) /mx
					else
						/ (?= #{delim_pattern}() | \\ ) /mx
					end
			}

			def initialize kind, interpreted, delim, heredoc = false
				if paren = CLOSING_PAREN[delim]
					delim, paren = paren, delim
					paren_depth = 1
				end
				if heredoc
					pattern = HEREDOC_PATTERN[ [delim, interpreted, heredoc == :indented] ]
					delim	= nil
				else
					pattern = STRING_PATTERN[ [delim, interpreted] ]
				end
				super kind, interpreted, delim, heredoc, paren, paren_depth, pattern
			end
		end unless defined? StringState
	
	end

end end
