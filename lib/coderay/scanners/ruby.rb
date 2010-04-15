module CodeRay
module Scanners

  # This scanner is really complex, since Ruby _is_ a complex language!
  #
  # It tries to highlight 100% of all common code,
  # and 90% of strange codes.
  #
  # It is optimized for HTML highlighting, and is not very useful for
  # parsing or pretty printing.
  #
  # For now, I think it's better than the scanners in VIM or Syntax, or
  # any highlighter I was able to find, except Caleb's RubyLexer.
  #
  # I hope it's also better than the rdoc/irb lexer.
  # 
  # Alias: +irb+
  class Ruby < Scanner

    include Streamable

    register_for :ruby
    file_extension 'rb'

    helper :patterns
    
    unless defined? EncodingError
      EncodingError = Class.new Exception  # :nodoc:
    end
    
  protected
    
    def scan_tokens tokens, options
      
      state = :initial
      last_state = nil
      method_call_expected = false
      value_expected = true
      heredocs = nil
      inline_block_stack = nil
      inline_block_curly_depth = 0
      # def_object_stack = nil
      # def_object_paren_depth = 0
      unicode = string.respond_to?(:encoding) && string.encoding.name == 'UTF-8'
      
      patterns = Patterns  # avoid constant lookup
      
      until eos?
        match = nil
        kind = nil

        if state.instance_of? patterns::StringState

          match = scan_until(state.pattern) || scan_until(/\z/)
          tokens << [match, :content] unless match.empty?
          break if eos?

          if state.heredoc and self[1]  # end of heredoc
            match = getch.to_s
            match << scan_until(/$/) unless eos?
            tokens << [match, :delimiter]
            tokens << [:close, state.type]
            state = state.next_state
            next
          end

          case match = getch

          when state.delim
            if state.paren_depth
              state.paren_depth -= 1
              if state.paren_depth > 0
                tokens << [match, :nesting_delimiter]
                next
              end
            end
            tokens << [match, :delimiter]
            if state.type == :regexp and not eos?
              modifiers = scan(/#{patterns::REGEXP_MODIFIERS}/ox)
              tokens << [modifiers, :modifier] unless modifiers.empty?
            end
            tokens << [:close, state.type]
            value_expected = false
            state = state.next_state

          when '\\'
            if state.interpreted
              if esc = scan(/ #{patterns::ESCAPE} /ox)
                tokens << [match + esc, :char]
              else
                tokens << [match, :error]
              end
            else
              case m = getch
              when state.delim, '\\'
                tokens << [match + m, :char]
              when nil
                tokens << [match, :error]
              else
                tokens << [match + m, :content]
              end
            end

          when '#'
            case peek(1)
            when '{'
              inline_block_stack ||= []
              inline_block_stack << [state, inline_block_curly_depth, heredocs]
              value_expected = true
              state = :initial
              inline_block_curly_depth = 1
              tokens << [:open, :inline]
              tokens << [match + getch, :inline_delimiter]
            when '$', '@'
              tokens << [match, :escape]
              last_state = state
              state = :initial
            else
              raise_inspect 'else-case # reached; #%p not handled' % 
                [peek(1)], tokens
            end

          when state.opening_paren
            state.paren_depth += 1
            tokens << [match, :nesting_delimiter]

          when /#{patterns::REGEXP_SYMBOLS}/ox
            tokens << [match, :function]

          else
            raise_inspect 'else-case " reached; %p not handled, state = %p' %
              [match, state], tokens

          end
          next

        else

          if match = scan(/[ \t\f]+/)
            kind = :space
            match << scan(/\s*/) unless eos? || heredocs
            value_expected = true if match.index(?\n)
            tokens << [match, kind]
            next
            
          elsif match = scan(/\\?\n/)
            kind = :space
            if match == "\n"
              value_expected = true
              state = :initial if state == :undef_comma_expected
            end
            if heredocs
              unscan  # heredoc scanning needs \n at start
              state = heredocs.shift
              tokens << [:open, state.type]
              heredocs = nil if heredocs.empty?
              next
            else
              match << scan(/\s*/) unless eos?
            end
            tokens << [match, kind]
            next
          
          elsif bol? && match = scan(/\#!.*/)
            tokens << [match, :doctype]
            next
            
          elsif match = scan(/\#.*/) or
             (bol? and match = scan(/#{patterns::RUBYDOC_OR_DATA}/o))
            kind = :comment
            tokens << [match, kind]
            next

          elsif state == :initial

            # IDENTS #
            if !method_call_expected and
               match = scan(unicode ? /#{patterns::METHOD_NAME}/uo :
                                      /#{patterns::METHOD_NAME}/o)
              value_expected = false
              kind = patterns::IDENT_KIND[match]
              if kind == :ident
                if match[/^[A-Z]/] && !match[/[!?]$/] && !match?(/\(/)
                  kind = :constant
                end
              elsif kind == :reserved
                state = patterns::KEYWORD_NEW_STATE[match]
                value_expected = true if patterns::KEYWORDS_EXPECTING_VALUE[match]
              end
              value_expected = true if !value_expected && check(/#{patterns::VALUE_FOLLOWS}/o)
            
            elsif method_call_expected and
               match = scan(unicode ? /#{patterns::METHOD_AFTER_DOT}/uo :
                                      /#{patterns::METHOD_AFTER_DOT}/o)
              kind =
                if method_call_expected == '::' && match[/^[A-Z]/] && !match?(/\(/)
                  :constant
                else
                  :ident
                end
              method_call_expected = false
              value_expected = check(/#{patterns::VALUE_FOLLOWS}/o)

            # OPERATORS #
            elsif not method_call_expected and match = scan(/ \.\.\.? | (\.|::) | [,\(\)\[\]\{\}] | ==?=? /x)
              value_expected = match !~ / [.\)\]\}] /x || match =~ /\A\.\./
              method_call_expected = self[1]
              kind = :operator
              if inline_block_stack
                case match
                when '{'
                  inline_block_curly_depth += 1
                when '}'
                  inline_block_curly_depth -= 1
                  if inline_block_curly_depth == 0  # closing brace of inline block reached
                    state, inline_block_curly_depth, heredocs = inline_block_stack.pop
                    inline_block_stack = nil if inline_block_stack.empty?
                    heredocs = nil if heredocs && heredocs.empty?
                    tokens << [match, :inline_delimiter]
                    kind = :inline
                    match = :close
                  end
                end
              end

            elsif match = scan(/ ['"] /mx)
              tokens << [:open, :string]
              kind = :delimiter
              state = patterns::StringState.new :string, match == '"', match  # important for streaming

            elsif match = scan(unicode ? /#{patterns::INSTANCE_VARIABLE}/uo :
                                         /#{patterns::INSTANCE_VARIABLE}/o)
              value_expected = false
              kind = :instance_variable

            elsif value_expected and match = scan(/\//)
              tokens << [:open, :regexp]
              kind = :delimiter
              interpreted = true
              state = patterns::StringState.new :regexp, interpreted, match

            elsif match = value_expected ? scan(/[-+]?#{patterns::NUMERIC}/o) : scan(/#{patterns::NUMERIC}/o)
              if method_call_expected
                kind = :error
                method_call_expected = false
              else
                kind = self[1] ? :float : :integer
              end
              value_expected = false

            elsif match = scan(unicode ? /#{patterns::SYMBOL}/uo :
                                         /#{patterns::SYMBOL}/o)
              case delim = match[1]
              when ?', ?"
                tokens << [:open, :symbol]
                tokens << [':', :symbol]
                match = delim.chr
                kind = :delimiter
                state = patterns::StringState.new :symbol, delim == ?", match
              else
                kind = :symbol
                value_expected = false
              end

            elsif match = scan(/ [-+!~^]=? | [*|&]{1,2}=? | >>? /x)
              value_expected = true
              kind = :operator

            elsif value_expected and match = scan(/#{patterns::HEREDOC_OPEN}/o)
              indented = self[1] == '-'
              quote = self[3]
              delim = self[quote ? 4 : 2]
              kind = patterns::QUOTE_TO_TYPE[quote]
              tokens << [:open, kind]
              tokens << [match, :delimiter]
              match = :close
              heredoc = patterns::StringState.new kind, quote != '\'',
                delim, (indented ? :indented : :linestart )
              heredocs ||= []  # create heredocs if empty
              heredocs << heredoc
              value_expected = false

            elsif value_expected and match = scan(/#{patterns::FANCY_START}/o)
              kind, interpreted = *patterns::FancyStringType.fetch(self[1]) do
                raise_inspect 'Unknown fancy string: %%%p' % k, tokens
              end
              tokens << [:open, kind]
              state = patterns::StringState.new kind, interpreted, self[2]
              kind = :delimiter

            elsif value_expected and match = scan(/#{patterns::CHARACTER}/o)
              value_expected = false
              kind = :integer

            elsif match = scan(/ [\/%]=? | <(?:<|=>?)? | [?:;] /x)
              value_expected = true
              kind = :operator

            elsif match = scan(/`/)
              if method_call_expected
                kind = :operator
                value_expected = true
              else
                tokens << [:open, :shell]
                kind = :delimiter
                state = patterns::StringState.new :shell, true, match
              end

            elsif match = scan(unicode ? /#{patterns::GLOBAL_VARIABLE}/uo :
                                         /#{patterns::GLOBAL_VARIABLE}/o)
              kind = :global_variable
              value_expected = false

            elsif match = scan(unicode ? /#{patterns::CLASS_VARIABLE}/uo :
                                         /#{patterns::CLASS_VARIABLE}/o)
              kind = :class_variable
              value_expected = false

            else
              if method_call_expected
                method_call_expected = false
                next
              end
              if !unicode
                # check for unicode
                debug, $DEBUG = $DEBUG, false
                begin
                  if check(/./mu).size > 1
                    # seems like we should try again with unicode
                    unicode = true
                  end
                rescue
                  # bad unicode char; use getch
                ensure
                  $DEBUG = debug
                end
                next if unicode
              end
              kind = :error
              match = getch

            end
            
            if last_state
              state = last_state
              last_state = nil
            end

          elsif state == :def_expected
            if match = scan(unicode ? /(?>#{patterns::METHOD_NAME_EX})(?!\.|::)/uo :
                                      /(?>#{patterns::METHOD_NAME_EX})(?!\.|::)/o)
              kind = :method
              state = :initial
            else
              last_state = :dot_expected
              state = :initial
              next
            end

          elsif state == :dot_expected
            if match = scan(/\.|::/)
              # invalid definition
              state = :def_expected
              kind = :operator
            else
              state = :initial
              next
            end

          elsif state == :module_expected
            if match = scan(/<</)
              kind = :operator
            else
              state = :initial
              if match = scan(unicode ? / (?:#{patterns::IDENT}::)* #{patterns::IDENT} /oux :
                                        / (?:#{patterns::IDENT}::)* #{patterns::IDENT} /ox)
                kind = :class
              else
                next
              end
            end

          elsif state == :undef_expected
            state = :undef_comma_expected
            if match = scan(unicode ? /(?>#{patterns::METHOD_NAME_EX})(?!\.|::)/uo :
                                      /(?>#{patterns::METHOD_NAME_EX})(?!\.|::)/o)
              kind = :method
            elsif match = scan(/#{patterns::SYMBOL}/o)
              case delim = match[1]
              when ?', ?"
                tokens << [:open, :symbol]
                tokens << [':', :symbol]
                match = delim.chr
                kind = :delimiter
                state = patterns::StringState.new :symbol, delim == ?", match
                state.next_state = :undef_comma_expected
              else
                kind = :symbol
              end
            else
              state = :initial
              next
            end

          elsif state == :undef_comma_expected
            if match = scan(/,/)
              kind = :operator
              state = :undef_expected
            else
              state = :initial
              next
            end

          elsif state == :alias_expected
            match = scan(unicode ? /(#{patterns::METHOD_NAME_OR_SYMBOL})([ \t]+)(#{patterns::METHOD_NAME_OR_SYMBOL})/uo :
                                   /(#{patterns::METHOD_NAME_OR_SYMBOL})([ \t]+)(#{patterns::METHOD_NAME_OR_SYMBOL})/o)
            
            if match
              tokens << [self[1], (self[1][0] == ?: ? :symbol : :method)]
              tokens << [self[2], :space]
              tokens << [self[3], (self[3][0] == ?: ? :symbol : :method)]
            end
            state = :initial
            next

          end
          
          if $CODERAY_DEBUG and not kind
            raise_inspect 'Error token %p in line %d' %
              [[match, kind], line], tokens, state
          end
          raise_inspect 'Empty token', tokens, state unless match

          tokens << [match, kind]
        end
      end

      # cleaning up
      if state.is_a? patterns::StringState
        tokens << [:close, state.type]
      end
      if inline_block_stack
        until inline_block_stack.empty?
          state, *more = inline_block_stack.pop
          tokens << [:close, :inline] if more
          tokens << [:close, state.type]
        end
      end

      tokens
    end

  end

end
end
