module CodeRay
module Scanners

  class AVRASM < Scanner

    register_for :avrasm

    RESERVED_WORDS = [
    ]

    PREDEFINED_TYPES = [
    ]

    PREDEFINED_CONSTANTS = [
    ]

    IDENT_KIND = CaseIgnoringWordList.new(:ident).
      add(RESERVED_WORDS, :reserved).
      add(PREDEFINED_TYPES, :pre_type).
      add(PREDEFINED_CONSTANTS, :pre_constant)

    ESCAPE = / [rbfnrtv\n\\'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} /x
    UNICODE_ESCAPE =  / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x

    def scan_tokens tokens, options

      state = :initial

      until eos?

        kind = nil
        match = nil

        case state

        when :initial

          if scan(/ \s+ | \\\n /x)
            kind = :space

          elsif scan(/;.*/x)
            kind = :comment

          elsif scan(/\.(\w*)/x)
            kind = :preprocessor
            state = :include_expected if self[1] == 'include'
          
          elsif scan(/@[0-9]+/)
            kind = :preprocessor

          elsif scan(/ [-+*\/=<>?:;,!&^|()\[\]{}~%]+ | \.(?!\d) /x)
            kind = :operator

          elsif scan(/r[0-9]+/i)
            # register R0-R31
            kind = :pre_constant

          elsif match = scan(/ [A-Za-z_][A-Za-z_0-9]* /x)
            kind = IDENT_KIND[match]
            if kind == :ident and check(/:(?!:)/)
              match << scan(/:/)
              kind = :label
            end

          elsif match = scan(/"/)
            tokens << [:open, :string]
            state = :string
            kind = :delimiter

          elsif scan(/ L?' (?: [^\'\n\\] | \\ #{ESCAPE} )? '? /ox)
            kind = :char

          elsif scan(/0[xX][0-9A-Fa-f]+/)
            kind = :integer

          elsif scan(/(?:0[0-7]+)(?![89.eEfF])/)
            kind = :integer

          elsif scan(/0[bB][0-9A-Fa-f]+/)
            kind = :integer

          elsif scan(/(?:\d+)(?![.eEfF])/)
            kind = :integer

          elsif scan(/\d[fF]?|\d*\.\d+(?:[eE][+-]?\d+)?[fF]?|\d+[eE][+-]?\d+[fF]?/)
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
            next
          elsif scan(/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox)
            kind = :char
          elsif scan(/ \\ | $ /x)
            tokens << [:close, :string]
            kind = :error
            state = :initial
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
            getch
            kind = :error

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
