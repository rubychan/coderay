module CodeRay
module Scanners
  
  # Scanner for Java.
  class Java < Scanner

    include Streamable
    register_for :java
    helper :builtin_types
    
    # http://java.sun.com/docs/books/tutorial/java/nutsandbolts/_keywords.html
    KEYWORDS = %w[
      assert break case catch continue default do else
      finally for if instanceof import new package
      return switch throw try typeof while
      debugger export
    ]  # :nodoc:
    RESERVED = %w[ const goto ]  # :nodoc:
    CONSTANTS = %w[ false null true ]  # :nodoc:
    MAGIC_VARIABLES = %w[ this super ]  # :nodoc:
    TYPES = %w[
      boolean byte char class double enum float int interface long
      short void
    ] << '[]'  # :nodoc: because int[] should be highlighted as a type
    DIRECTIVES = %w[
      abstract extends final implements native private protected public
      static strictfp synchronized throws transient volatile
    ]  # :nodoc:
    
    IDENT_KIND = WordList.new(:ident).
      add(KEYWORDS, :keyword).
      add(RESERVED, :reserved).
      add(CONSTANTS, :pre_constant).
      add(MAGIC_VARIABLES, :local_variable).
      add(TYPES, :type).
      add(BuiltinTypes::List, :pre_type).
      add(BuiltinTypes::List.select { |builtin| builtin[/(Error|Exception)$/] }, :exception).
      add(DIRECTIVES, :directive)  # :nodoc:

    ESCAPE = / [bfnrtv\n\\'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} /x  # :nodoc:
    UNICODE_ESCAPE =  / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x  # :nodoc:
    STRING_CONTENT_PATTERN = {
      "'" => /[^\\']+/,
      '"' => /[^\\"]+/,
      '/' => /[^\\\/]+/,
    }  # :nodoc:
    IDENT = /[a-zA-Z_][A-Za-z_0-9]*/  # :nodoc:
    
  protected
    
    def scan_tokens tokens, options

      state = :initial
      string_delimiter = nil
      package_name_expected = false
      class_name_follows = false
      last_token_dot = false

      until eos?

        kind = nil
        match = nil
        
        case state

        when :initial

          if match = scan(/ \s+ | \\\n /x)
            tokens << [match, :space]
            next
          
          elsif match = scan(%r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .* ) !mx)
            tokens << [match, :comment]
            next
          
          elsif package_name_expected && scan(/ #{IDENT} (?: \. #{IDENT} )* /ox)
            kind = package_name_expected
          
          elsif match = scan(/ #{IDENT} | \[\] /ox)
            kind = IDENT_KIND[match]
            if last_token_dot
              kind = :ident
            elsif class_name_follows
              kind = :class
              class_name_follows = false
            else
              case match
              when 'import'
                package_name_expected = :include
              when 'package'
                package_name_expected = :namespace
              when 'class', 'interface'
                class_name_follows = true
              end
            end
          
          elsif scan(/ \.(?!\d) | [,?:()\[\]}] | -- | \+\+ | && | \|\| | \*\*=? | [-+*\/%^~&|<>=!]=? | <<<?=? | >>>?=? /x)
            kind = :operator
          
          elsif scan(/;/)
            package_name_expected = false
            kind = :operator
          
          elsif scan(/\{/)
            class_name_follows = false
            kind = :operator
          
          elsif check(/[\d.]/)
            if scan(/0[xX][0-9A-Fa-f]+/)
              kind = :hex
            elsif scan(/(?>0[0-7]+)(?![89.eEfF])/)
              kind = :oct
            elsif scan(/\d+[fFdD]|\d*\.\d+(?:[eE][+-]?\d+)?[fFdD]?|\d+[eE][+-]?\d+[fFdD]?/)
              kind = :float
            elsif scan(/\d+[lL]?/)
              kind = :integer
            end

          elsif match = scan(/["']/)
            tokens << [:open, :string]
            state = :string
            string_delimiter = match
            kind = :delimiter

          elsif scan(/ @ #{IDENT} /ox)
            kind = :annotation

          else
            getch
            kind = :error

          end

        when :string
          if scan(STRING_CONTENT_PATTERN[string_delimiter])
            kind = :content
          elsif match = scan(/["'\/]/)
            tokens << [match, :delimiter]
            tokens << [:close, state]
            string_delimiter = nil
            state = :initial
            next
          elsif state == :string && (match = scan(/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox))
            if string_delimiter == "'" && !(match == "\\\\" || match == "\\'")
              kind = :content
            else
              kind = :char
            end
          elsif scan(/\\./m)
            kind = :content
          elsif scan(/ \\ | $ /x)
            tokens << [:close, :delimiter]
            kind = :error
            state = :initial
          else
            raise_inspect "else case \" reached; %p not handled." % peek(1), tokens
          end

        else
          raise_inspect 'Unknown state', tokens

        end

        match ||= matched
        if $CODERAY_DEBUG and not kind
          raise_inspect 'Error token %p in line %d' %
            [[match, kind], line], tokens
        end
        raise_inspect 'Empty token', tokens unless match
        
        last_token_dot = match == '.'
        
        tokens << [match, kind]

      end

      if state == :string
        tokens << [:close, state]
      end

      tokens
    end

  end

end
end
