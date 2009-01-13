module CodeRay
module Scanners

  load :java

  class Groovy < Java

    include Streamable
    register_for :groovy
    
    # TODO: Check this!
    KEYWORDS = Java::KEYWORDS + %w[
      def assert as in
    ]
    KEYWORDS_EXPECTING_VALUE = WordList.new.add %w[
      case instanceof new return throw typeof while as assert in
    ]
    
    MAGIC_VARIABLES = Java::MAGIC_VARIABLES + %w[ it ]
    # DIRECTIVES = %w[
    #   abstract extends final implements native private protected public
    #   static strictfp synchronized threadsafe throws transient volatile
    # ]
    
    IDENT_KIND = WordList.new(:ident).
      add(KEYWORDS, :keyword).
      add(MAGIC_VARIABLES, :local_variable).
      add(TYPES, :type).
      add(BuiltinTypes::List, :pre_type).
      add(DIRECTIVES, :directive)
    
    ESCAPE = / [bfnrtv$\n\\'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} /x
    UNICODE_ESCAPE =  / u[a-fA-F0-9]{4} /x  # no 4-byte unicode chars? U[a-fA-F0-9]{8}
    REGEXP_ESCAPE =  / [bBdDsSwW] /x
    STRING_CONTENT_PATTERN = {
      "'" => /[^\\$'\n]+/,
      '"' => /[^\\$"\n]+/,
      "'''" => /(?>[^\\$']+|'(?!''))+/,
      '"""' => /(?>[^\\$"]+|"(?!""))+/,
      '/' => /[^\\$\/\n]+/,
    }
    
    def scan_tokens tokens, options

      state = :initial
      string_delimiter = nil
      import_clause = class_name_follows = last_token_dot = after_def = false
      value_expected = true

      until eos?

        kind = nil
        match = nil
        
        case state

        when :initial

          if match = scan(/ \s+ | \\\n /x)
            tokens << [match, :space]
            if match.index ?\n
              import_clause = after_def = false
              value_expected = true
            end
            next
          
          elsif scan(%r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .* ) !mx)
            value_expected = true
            after_def = false
            kind = :comment
          
          elsif bol? && scan(/ \#!.* /x)
            kind = :doctype
          
          elsif import_clause && scan(/ (?!as) #{IDENT} (?: \. #{IDENT} )* (?: \.\* )? /ox)
            after_def = value_expected = false
            kind = :include
          
          elsif match = scan(/ #{IDENT} | \[\] /ox)
            kind = IDENT_KIND[match]
            value_expected = (kind == :keyword) && KEYWORDS_EXPECTING_VALUE[match]
            if last_token_dot
              kind = :ident
            elsif class_name_follows
              kind = :class
              class_name_follows = false
            elsif after_def && check(/\s*[({]/)
              kind = :method
              after_def = false
            elsif kind == :ident && check(/:/)
              kind = :key
            else
              class_name_follows = true if match == 'class' || (import_clause && match == 'as')
              import_clause = match == 'import'
              after_def = true if match == 'def'
            end
          
          # TODO: ~'...', ~"..." and ~/.../ style regexps
          elsif scan(/ \.\.<? | \*?\.(?!\d)@? | \.& | \?:? | [,?:(\[] | -[->] | \+\+ |
              && | \|\| | \*\*=? | ==?~ | [-+*%^~&|<>=!]=? | <<<?=? | >>>?=? /x)
            value_expected = true
            after_def = false
            kind = :operator
          
          elsif scan(/ [)\]}]+ /x)
            value_expected = after_def = false
          
          elsif scan(/;/)
            import_clause = after_def = false
            value_expected = true
            kind = :operator
          
          elsif scan(/\{/)
            class_name_follows = after_def = false
            value_expected = true
            kind = :operator
          
          elsif check(/[\d.]/)
            after_def = value_expected = false
            if scan(/0[xX][0-9A-Fa-f]+/)
              kind = :hex
            elsif scan(/(?>0[0-7]+)(?![89.eEfF])/)
              kind = :oct
            elsif scan(/\d+[fFdD]|\d*\.\d+(?:[eE][+-]?\d+)?[fFdD]?|\d+[eE][+-]?\d+[fFdD]?/)
              kind = :float
            elsif scan(/\d+[lLgG]?/)
              kind = :integer
            end

          elsif match = scan(/'''|"""/)
            after_def = value_expected = false
            state = :multiline_string
            tokens << [:open, :string]
            string_delimiter = match
            kind = :delimiter

          elsif match = scan(/["']/)
            after_def = value_expected = false
            state = match == '/' ? :regexp : :string
            tokens << [:open, state]
            string_delimiter = match
            kind = :delimiter

          elsif value_expected && (match = scan(/\/(?=\S)/))
            after_def = value_expected = false
            tokens << [:open, :regexp]
            state = :regexp
            string_delimiter = '/'
            kind = :delimiter

          elsif scan(/ @ #{IDENT} /ox)
            after_def = value_expected = false
            kind = :annotation

          elsif scan(/\//)
            after_def = false
            value_expected = true
            kind = :operator
          
          else
            getch
            kind = :error

          end

        when :string, :regexp, :multiline_string
          if scan(STRING_CONTENT_PATTERN[string_delimiter])
            kind = :content
          elsif match = scan(state == :multiline_string ? /'''|"""/ : /["'\/]/)
            tokens << [match, :delimiter]
            if state == :regexp
              modifiers = scan(/[ix]+/)
              tokens << [modifiers, :modifier] if modifiers && !modifiers.empty?
            end
            state = :string if state == :multiline_string
            tokens << [:close, state]
            string_delimiter = nil
            after_def = value_expected = false
            state = :initial
            next
          
          elsif state == :string && (match = scan(/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox))
            if string_delimiter == "'" && !(match == "\\\\" || match == "\\'")
              kind = :content
            else
              kind = :char
            end
          elsif state == :regexp && scan(/ \\ (?: #{ESCAPE} | #{REGEXP_ESCAPE} | #{UNICODE_ESCAPE} ) /mox)
            kind = :char
          
          elsif match = scan(/ \$ #{IDENT} /mox)
            tokens << [:open, :inline]
            tokens << ['$', :inline_delimiter]
            match = match[1..-1]
            tokens << [match, IDENT_KIND[match]]
            tokens << [:close, :inline]
            next
          elsif match = scan(/ \$ \{ [^}]* \} /mox)
            # TODO: recursive inline strings
            tokens << [:open, :inline]
            tokens << ['${', :inline_delimiter]
            tokens << [match[2..-2], :ident]
            tokens << ['}', :inline_delimiter]
            tokens << [:close, :inline]
            next
          
          elsif scan(/ \\. | \$ /mx)
            kind = :content
          
          elsif scan(/ \\ | $ /x)
            tokens << [:close, :delimiter]
            kind = :error
            after_def = value_expected = false
            state = :initial
          else
            raise_inspect "else case \" reached; %p not handled." % peek(1), tokens
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
        
        last_token_dot = match == '.'
        
        tokens << [match, kind]

      end

      if [:string, :regexp].include? state
        tokens << [:close, state]
      end

      tokens
    end

  end

end
end
