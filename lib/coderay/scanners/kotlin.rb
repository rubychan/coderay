module CodeRay
  module Scanners
    load :java

    class Kotlin < Java
      register_for :kotlin
      file_extension 'kt'

      KOTLIN_KEYWORDS = %w[
        package import
        as? as is 
        val var 
        class interface object fun init get set
            in out
            if when else for while do return break continue
      ]

      KOTLIN_MODIFIERS = %w[
        annotation enum data sealed companion
        abstract open final 
        public protected private internal 
        inline suspend
        inner
      ]

      TYPES = %w[
        Boolean Byte Char class Double Float Int Long Short Unit Nothing Any
      ]

      STRING_CONTENT_PATTERN = {
        "'" => /[^\\'$]+/,
        '"' => /[^\\"$]+/
      } # :nodoc:s

      IDENT_KIND = Java::IDENT_KIND.dup.
        add(TYPES, :type).
        add(KOTLIN_KEYWORDS, :keyword).
        add(KOTLIN_MODIFIERS, :keyword) # :nodoc:

      def setup
        @state = :initial
      end

      def scan_tokens encoder, options
        string_delimiter = nil
        state = options[:state] || @state
        last_token_dot = false
        class_name_follows = false
        delimiters = []
        states = []

        until eos?

          case state

          when :initial
            if (match = scan(/ \s+ | \\\n /x))
              encoder.text_token match, :space
              next
            elsif (match = scan(%r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .* ) !mx))
              encoder.text_token match, :comment
              next
            elsif (match = scan(/ TODO \( /ox))
              encoder.text_token "TODO", :comment
              encoder.text_token "(", :operator
            elsif (match = scan(/ #{IDENT} /ox))
              kind = IDENT_KIND[match]
              if last_token_dot
                kind = :ident
              elsif class_name_follows
                kind = :class
                class_name_follows = false
              else
                # noinspection RubyEmptyElseBlockInspection
                case match
                when 'import'
                  :include
                when 'package'
                  :namespace
                when 'class', 'interface'
                  class_name_follows = true
                end
              end
              encoder.text_token match, kind
            elsif (match = scan(/ \.(?!\d) | [,?:()\[\]] | -- | \+\+ | && | \|\| | \*\*=? | [-+*\/%^~&|<>=!]=? /x))
              encoder.text_token match, :operator
            elsif (match = scan(/\{/))
              class_name_follows = false
              encoder.text_token match, :operator
              states << :initial
            elsif (match = scan(/\}/))
              encoder.text_token match, :operator

              unless states.empty?
                state = states.pop

                if [:multiline_string, :string].include? state
                  string_delimiter = delimiters.pop
                  encoder.end_group :initial
                end
              end
            elsif (match = scan(/"""/))
              state = :multiline_string
              encoder.begin_group :string
              encoder.text_token match, :delimiter
            elsif (match = scan(/["']/))
              state = :string
              encoder.begin_group state
              string_delimiter = match
              encoder.text_token match, :delimiter
            elsif check(/[\d.]/)
              if (match = scan(/0[xX][0-9A-Fa-f]+/))
                encoder.text_token match, :hex
              elsif (match = scan(/(?>0[0-7]+)(?![89.eEfF])/))
                encoder.text_token match, :octal
              elsif (match = scan(/\d+[fFdD]|\d*\.\d+(?:[eE][+-]?\d+)?[fFdD]?|\d+[eE][+-]?\d+[fFdD]?/))
                encoder.text_token match, :float
              elsif (match = scan(/\d+[lL]?/))
                encoder.text_token match, :integer
              end

            elsif (match = scan(/ @ #{IDENT} /ox))
              encoder.text_token match, :annotation

            else
              encoder.text_token getch, :error
            end

          when :string
            if (match = scan(/\$\{/))
              encoder.text_token match, :operator

              state = :initial
              encoder.begin_group state

              delimiters << string_delimiter
              states << :string
              string_delimiter = nil
            elsif (match = scan(/ \$ #{IDENT} /ox))
              encoder.text_token match, :ident
            elsif (match = scan(STRING_CONTENT_PATTERN[string_delimiter]))
              encoder.text_token match, :content
            elsif (match = scan(/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox))
              if string_delimiter == "'" && !(%W[\\\\ \\'].include? match)
                encoder.text_token match, :content
              else
                encoder.text_token match, :char
              end
            elsif (match = scan(/["']/))
              encoder.text_token match, :delimiter
              encoder.end_group state
              state = :initial
              string_delimiter = nil
            elsif (match = scan(/ \\ | $ /x))
              encoder.end_group state
              state = :initial
              encoder.text_token match, :error unless match.empty?
            else
              raise_inspect "else case \" reached; %p not handled." % peek(1), encoder
            end
          when :multiline_string
            if (match = scan(/\$\{/))
              encoder.text_token match, :operator

              state = :initial
              encoder.begin_group state

              delimiters << nil
              states << :multiline_string
            elsif (match = scan(/ \$ #{IDENT} /ox))
              encoder.text_token match, :ident
            elsif (match = scan(/ [^$\\"]+ /x))
              encoder.text_token match, :content
            elsif (match = scan(/"""/x))
              encoder.text_token match, :delimiter
              encoder.end_group :string
              state = :initial
              string_delimiter = nil
            elsif (match = scan(/"/))
              encoder.text_token match, :content
            else
              raise_inspect "else case \" reached; %p not handled." % peek(1), encoder
            end
          else
            raise_inspect 'Unknown state', encoder
          end

        end
      end
    end
  end
end
