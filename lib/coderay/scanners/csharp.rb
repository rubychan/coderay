module CodeRay
module Scanners

  # Scanner for C#.
  # https://msdn.microsoft.com/en-us/library/ms228593.aspx
  class CSharp < Scanner

    register_for :csharp
    file_extension 'cs'
    title 'C#'
    
    KEYWORDS = [
      'as', 'break', 'case', 'catch', 'class', 'const', 'continue', 'default',
      'delegate', 'do', 'else', 'enum', 'event', 'finally', 'for', 'foreach',
      'goto', 'if', 'in', 'interface', 'is', 'lock', 'namespace', 'new',
      'operator', 'out', 'params', 'readonly', 'ref', 'return', 'sizeof',
      'stackalloc', 'struct', 'switch', 'throw', 'try', 'typeof', 'using',
      'while',
    ]  # :nodoc:

    PREDEFINED_TYPES = [
      'bool', 'byte', 'char', 'decimal', 'double', 'float', 'int', 'long',
      'object', 'sbyte', 'short', 'string', 'uint', 'ulong', 'ushort',
    ]  # :nodoc:
    PREDEFINED_CONSTANTS = [
      'false', 'null', 'true',
    ]  # :nodoc:
    PREDEFINED_VARIABLES = [
      'base', 'this',
    ]  # :nodoc:
    DIRECTIVES = [
      'abstract', 'checked', 'explicit', 'extern', 'fixed', 'implicit',
      'internal', 'override', 'private', 'protected', 'public', 'sealed',
      'static', 'unchecked', 'unsafe', 'virtual', 'void', 'volatile',
    ]  # :nodoc:
    CONTEXTUAL_KEYWORDS = [
      'get', 'set', 'var', 'yield',
      #'add', 'alias', 'ascending', 'async', 'await', 'descending', 'dynamic',
      #'from', 'global', 'group', 'into', 'join', 'let', 'orderby', 'partial',
      #'remove', 'select', 'value', 'where',
    ]  # :nodoc:
    
    IDENT_KIND = WordList.new(:ident).
      add(KEYWORDS, :keyword).
      add(CONTEXTUAL_KEYWORDS, :keyword).
      add(PREDEFINED_TYPES, :predefined_type).
      add(PREDEFINED_VARIABLES, :local_variable).
      add(DIRECTIVES, :directive).
      add(PREDEFINED_CONSTANTS, :predefined_constant)  # :nodoc:

    SINGLE_CHARACTER = / [^'\\\r\n] /x  # :nodoc:
    ESCAPE = / \\ (?:
        ['"\\0abfnrtv] |                   # simple-escape-sequence
        x[0-9A-Fa-f]{1,4} |                # hexadecimal-escape-sequence
        u[0-9A-Fa-f]{4} | U[0-9A-Fa-f]{8}  # unicode-escape-sequence
        ) /x  # :nodoc:
    SINGLE_REGULAR_STRING_LITERAL_CHARACTER = / [^"\\\r\n] /x  # :nodoc:
    
  protected
    
    def scan_tokens encoder, options

      state = :initial
      label_expected = true
      case_expected = false
      label_expected_before_preproc_line = nil
      in_preproc_line = false

      until eos?

        case state

        when :initial

          if match = scan(/ \s+ /x)
            if in_preproc_line && match.index(?\n)
              in_preproc_line = false
              label_expected = label_expected_before_preproc_line
            end
            encoder.text_token match, :space

          elsif match = scan(%r! // [^\n]* | /\* (?: .*? \*/ | .* ) !mx)
            encoder.text_token match, :comment

          elsif match = scan(/ \# \s* if \s* false /x)
            match << scan_until(/ ^\# (?:elif|else|endif) .*? $ | \z /xm) unless eos?
            encoder.text_token match, :comment

          elsif match = scan(/ [-+*=<>?:;,!&^|()\[\]{}~%]+ | \/=? | \.(?!\d) /x)
            label_expected = match =~ /[;\{\}]/
            if case_expected
              label_expected = true if match == ':'
              case_expected = false
            end
            encoder.text_token match, :operator

          elsif match = scan(/ [A-Za-z_][A-Za-z_0-9]* /x)
            kind = IDENT_KIND[match]
            if kind == :ident && label_expected &&  !in_preproc_line && scan(/:(?!:)/)
              kind = :label
              match << matched
            else
              label_expected = false
              if kind == :keyword
                case match
                when 'class', 'interface', 'struct'
                  state = :class_name_expected
                when 'case', 'default'
                  case_expected = true
                end
              end
            end
            encoder.text_token match, kind

          elsif match = scan(/"/)
            encoder.begin_group :regular_string
            state = :regular_string
            encoder.text_token match, :delimiter

          elsif match = scan(/@"/)
            encoder.begin_group :verbatim_string
            state = :verbatim_string
            encoder.text_token match, :delimiter

          elsif match = scan(/#[ \t]*(\w*)/)
            encoder.text_token match, :preprocessor
            in_preproc_line = true
            label_expected_before_preproc_line = label_expected

          elsif match = scan(/ ' (?: #{SINGLE_CHARACTER} | #{ESCAPE} )? '? /ox)
            label_expected = false
            encoder.text_token match, :char

          elsif match = scan(/0X[0-9A-F]+(?:UL?|LU?|)/i)
            label_expected = false
            encoder.text_token match, :hex

          elsif match = scan(/(?:0[0-7]+)(?![89.DEFM])(?:UL?|LU?|)/i)
            label_expected = false
            encoder.text_token match, :octal

          elsif match = scan(/(?:\d+)(?![.DEFM])(?:UL?|LU?|)/i)
            label_expected = false
            encoder.text_token match, :integer

          elsif match = scan(/\d*\.\d+(?:E[+-]?\d+)?[DFM]?|\d+E[+-]?\d+[DFM]?|\d[DFM]?/i)
            label_expected = false
            encoder.text_token match, :float

          else
            encoder.text_token getch, :error

          end

        when :regular_string
          if match = scan(/ #{SINGLE_REGULAR_STRING_LITERAL_CHARACTER}+ /ox)
            encoder.text_token match, :content
          elsif match = scan(/"/)
            encoder.text_token match, :delimiter
            encoder.end_group :regular_string
            state = :initial
            label_expected = false
          elsif match = scan(/ #{ESCAPE} /ox)
            encoder.text_token match, :char
          elsif match = scan(/ \\ | $ /x)
            encoder.end_group :regular_string
            encoder.text_token match, :error unless match.empty?
            state = :initial
            label_expected = false
          else
            raise_inspect "else case \" reached; %p not handled." % peek(1), encoder
          end

        when :verbatim_string
          if match = scan(/[^"]+/m)
            encoder.text_token match, :content
          elsif match = scan(/""/)
            encoder.text_token match, :char
          elsif match = scan(/"/)
            encoder.text_token match, :delimiter
            encoder.end_group :verbatim_string
            state = :initial
            label_expected = false
          else
            raise_inspect "else case @\" reached; %p not handled." % peek(1), encoder
          end

        when :class_name_expected
          if match = scan(/ [A-Za-z_][A-Za-z_0-9]* /x)
            encoder.text_token match, :class
            state = :initial

          elsif match = scan(/\s+/)
            encoder.text_token match, :space

          else
            encoder.text_token getch, :error
            state = :initial

          end
          
        else
          raise_inspect 'Unknown state', encoder

        end

      end

      if state == :regular_string || state == :verbatim_string
        encoder.end_group state
      end

      encoder
    end

  end

end
end
