module CodeRay
module Scanners

  class C < Scanner

    include Streamable
    
    register_for :c
    file_extension 'c'

    RESERVED_WORDS = [
      'asm', 'break', 'case', 'continue', 'default', 'do',
      'else', 'enum', 'for', 'goto', 'if', 'return',
      'sizeof', 'struct', 'switch', 'typedef', 'union', 'while',
      'restrict',  # added in C99
    ]

    PREDEFINED_TYPES = [
      'int', 'long', 'short', 'char',
      'signed', 'unsigned', 'float', 'double',
      'bool', 'complex',  # added in C99
    ]

    PREDEFINED_CONSTANTS = [
      'EOF', 'NULL',
      'true', 'false',  # added in C99
    ]
    DIRECTIVES = [
      'auto', 'extern', 'register', 'static', 'void',
      'const', 'volatile',  # added in C89
      'inline',  # added in C99
    ]

    IDENT_KIND = WordList.new(:ident).
      add(RESERVED_WORDS, :reserved).
      add(PREDEFINED_TYPES, :pre_type).
      add(DIRECTIVES, :directive).
      add(PREDEFINED_CONSTANTS, :pre_constant)

    ESCAPE = / [rbfntv\n\\'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} /x
    UNICODE_ESCAPE =  / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x

    def scan_tokens tokens, options

      state = :initial
      label_expected = true

      until eos?

        kind = nil
        match = nil
        
        case state

        when :initial

          if match = scan(/ \s+ | \\\n /x)
            label_expected = true if !label_expected && match.index(?\n)
            tokens << [match, :space]
            next

          elsif scan(%r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .* ) !mx)
            kind = :comment

          elsif match = scan(/ \# \s* if \s* 0 /x)
            match << scan_until(/ ^\# (?:elif|else|endif) .*? $ | \z /xm) unless eos?
            kind = :comment

          elsif match = scan(/ [-+*=<>?:;,!&^|()\[\]{}~%]+ | \/=? | \.(?!\d) /x)
            label_expected = match =~ /[;\{\}]/
            kind = :operator

          elsif match = scan(/ [A-Za-z_][A-Za-z_0-9]* /x)
            kind = IDENT_KIND[match]
            if kind == :ident && label_expected && scan(/:(?!:)/)
              kind = :label
              match << matched
              label_expected = true
            else
              label_expected = false
            end

          elsif scan(/\$/)
            kind = :ident
          
          elsif match = scan(/L?"/)
            tokens << [:open, :string]
            if match[0] == ?L
              tokens << ['L', :modifier]
              match = '"'
            end
            state = :string
            kind = :delimiter

          elsif scan(/#[ \t]*(\w*)/)
            kind = :preprocessor  # FIXME multiline preprocs
            state = :include_expected if self[1] == 'include'

          elsif scan(/ L?' (?: [^\'\n\\] | \\ #{ESCAPE} )? '? /ox)
            label_expected = false
            kind = :char

          elsif scan(/0[xX][0-9A-Fa-f]+/)
            label_expected = false
            kind = :hex

          elsif scan(/(?:0[0-7]+)(?![89.eEfF])/)
            label_expected = false
            kind = :oct

          elsif scan(/(?:\d+)(?![.eEfF])L?L?/)
            label_expected = false
            kind = :integer

          elsif scan(/\d[fF]?|\d*\.\d+(?:[eE][+-]?\d+)?[fF]?|\d+[eE][+-]?\d+[fF]?/)
            label_expected = false
            kind = :float

          else
            getch
            kind = :error

          end

        when :string
          if scan(/[^\\\n"]+/)
            kind = :content
          elsif scan(/"/)
            tokens << ['"', :delimiter]
            tokens << [:close, :string]
            state = :initial
            label_expected = false
            next
          elsif scan(/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox)
            kind = :char
          elsif scan(/ \\ | $ /x)
            tokens << [:close, :string]
            kind = :error
            state = :initial
            label_expected = false
          else
            raise_inspect "else case \" reached; %p not handled." % peek(1), tokens
          end

        when :include_expected
          if scan(/<[^>\n]+>?|"[^"\n\\]*(?:\\.[^"\n\\]*)*"?/)
            kind = :include
            state = :initial

          elsif match = scan(/\s+/)
            kind = :space
            state = :initial if match.index ?\n

          else
            state = :initial
            next

          end

        else
          raise_inspect 'Unknown state', tokens

        end

        match ||= matched
        if $DEBUG and not kind
          raise_inspect 'Error token %p in line %d' %
            [[match, kind], line], tokens
        end
        raise_inspect 'Empty token', tokens unless match

        tokens << [match, kind]

      end

      if state == :string
        tokens << [:close, :string]
      end

      tokens
    end

  end

end
end
