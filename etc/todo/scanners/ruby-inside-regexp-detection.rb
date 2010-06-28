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

    register_for :ruby
    file_extension 'rb'

    helper :patterns
    
    unless defined? EncodingError
      EncodingError = Class.new Exception  # :nodoc:
    end
    
  protected
    
    def setup
      @state = :initial
    end
    
    def scan_tokens encoder, options
      
      patterns = Patterns  # avoid constant lookup
      
      state = @state
      if state.instance_of? patterns::StringState
        encoder.begin_group state.type
      end
      
      last_state = nil
      
      method_call_expected = false
      value_expected = true
      
      heredocs = nil
      inline_block_stack = nil
      inline_block_curly_depth = 0
      
      # def_object_stack = nil
      # def_object_paren_depth = 0
      
      unicode = string.respond_to?(:encoding) && string.encoding.name == 'UTF-8'
      
      until eos?

        if state.instance_of? patterns::StringState

          match = scan_until(state.pattern) || scan_until(/\z/)
          encoder.text_token match, :content unless match.empty?
          break if eos?

          if state.heredoc and self[1]  # end of heredoc
            match = getch.to_s
            match << scan_until(/$/) unless eos?
            encoder.text_token match, :delimiter
            encoder.end_group state.type
            state = state.next_state
            next
          end

          case match = getch

          when state.delim
            if state.paren_depth
              state.paren_depth -= 1
              if state.paren_depth > 0
                encoder.text_token match, :nesting_delimiter
                next
              end
            end
            encoder.text_token match, :delimiter
            if state.type == :regexp and not eos?
              modifiers = scan(/#{patterns::REGEXP_MODIFIERS}/ox)
              encoder.text_token modifiers, :modifier unless modifiers.empty?
            end
            encoder.end_group state.type
            value_expected = false
            state = state.next_state

          when '\\'
            if state.interpreted
              if esc = scan(/ #{patterns::ESCAPE} /ox)
                encoder.text_token match + esc, :char
              else
                encoder.text_token match, :error
              end
            else
              case m = getch
              when state.delim, '\\'
                encoder.text_token match + m, :char
              when nil
                encoder.text_token match, :content
              else
                encoder.text_token match + m, :content
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
              encoder.begin_group :inline
              encoder.text_token match + getch, :inline_delimiter
            when '$', '@'
              encoder.text_token match, :escape
              last_state = state
              state = :initial
            else
              raise_inspect 'else-case # reached; #%p not handled' % 
                [peek(1)], encoder
            end

          when state.opening_paren
            state.paren_depth += 1
            encoder.text_token match, :nesting_delimiter

          when /#{patterns::REGEXP_SYMBOLS}/ox
            encoder.text_token match, :function

          else
            raise_inspect 'else-case " reached; %p not handled, state = %p' %
              [match, state], encoder

          end

        else

          if match = scan(/[ \t\f]+/)
            match << scan(/\s*/) unless eos? || heredocs
            value_expected = true if match.index(?\n)
            encoder.text_token match, :space
            
          elsif match = scan(/\\?\n/)
            if match == "\n"
              value_expected = true
              state = :initial if state == :undef_comma_expected
            end
            if heredocs
              unscan  # heredoc scanning needs \n at start
              state = heredocs.shift
              encoder.begin_group state.type
              heredocs = nil if heredocs.empty?
              next
            else
              match << scan(/\s*/) unless eos?
            end
            encoder.text_token match, :space
          
          elsif bol? && match = scan(/\#!.*/)
            encoder.text_token match, :doctype
            
          elsif match = scan(/\#.*/) or
             (bol? and match = scan(/#{patterns::RUBYDOC_OR_DATA}/o))
            encoder.text_token match, :comment

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
              encoder.text_token match, kind
            
            elsif method_call_expected and
               match = scan(unicode ? /#{patterns::METHOD_AFTER_DOT}/uo :
                                      /#{patterns::METHOD_AFTER_DOT}/o)
              if method_call_expected == '::' && match[/^[A-Z]/] && !match?(/\(/)
                encoder.text_token match, :constant
              else
                encoder.text_token match, :ident
              end
              method_call_expected = false
              value_expected = check(/#{patterns::VALUE_FOLLOWS}/o)

            # OPERATORS #
            elsif not method_call_expected and match = scan(/ \.\.\.? | (\.|::) | [,\(\)\[\]\{\}] | ==?=? /x)
              value_expected = match !~ / [.\)\]\}] /x || match =~ /\A\.\./
              method_call_expected = self[1]
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
                    encoder.text_token match, :inline_delimiter
                    encoder.end_group :inline
                    next
                  end
                end
              end
              encoder.text_token match, :operator

            elsif match = scan(/ ['"] /mx)
              encoder.begin_group :string
              encoder.text_token match, :delimiter
              state = patterns::StringState.new :string, match == '"', match  # important for streaming

            elsif match = scan(unicode ? /#{patterns::INSTANCE_VARIABLE}/uo :
                                         /#{patterns::INSTANCE_VARIABLE}/o)
              value_expected = false
              encoder.text_token match, :instance_variable

            elsif value_expected and match?(/\//)
              encoder.begin_group :regexp
              if match?(/\/#{patterns::REGEXP_MODIFIERS}x#{patterns::REGEXP_MODIFIERS}[ \t]*(?:\n|#|\z|[,\)\]])/o)
                # most likely a false positive, the end of an extended regexp
                # so ignore this one and pretend we're inside the regexp
              else
                encoder.text_token getch, :delimiter
              end
              interpreted = true
              state = patterns::StringState.new :regexp, interpreted, '/'

            elsif match = scan(value_expected ? /[-+]?#{patterns::NUMERIC}/o : /#{patterns::NUMERIC}/o)
              if method_call_expected
                encoder.text_token match, :error
                method_call_expected = false
              else
                encoder.text_token match, self[1] ? :float : :integer
              end
              value_expected = false

            elsif match = scan(unicode ? /#{patterns::SYMBOL}/uo :
                                         /#{patterns::SYMBOL}/o)
              case delim = match[1]
              when ?', ?"
                encoder.begin_group :symbol
                encoder.text_token ':', :symbol
                match = delim.chr
                encoder.text_token match, :delimiter
                state = patterns::StringState.new :symbol, delim == ?", match
              else
                encoder.text_token match, :symbol
                value_expected = false
              end

            elsif match = scan(/ [-+!~^]=? | [*|&]{1,2}=? | >>? /x)
              value_expected = true
              encoder.text_token match, :operator

            elsif value_expected and match = scan(/#{patterns::HEREDOC_OPEN}/o)
              indented = self[1] == '-'
              quote = self[3]
              delim = self[quote ? 4 : 2]
              kind = patterns::QUOTE_TO_TYPE[quote]
              encoder.begin_group kind
              encoder.text_token match, :delimiter
              encoder.end_group kind
              heredoc = patterns::StringState.new kind, quote != '\'',
                delim, (indented ? :indented : :linestart )
              heredocs ||= []  # create heredocs if empty
              heredocs << heredoc
              value_expected = false

            elsif value_expected and match = scan(/#{patterns::FANCY_START}/o)
              kind, interpreted = *patterns::FancyStringType.fetch(self[1]) do
                raise_inspect 'Unknown fancy string: %%%p' % k, encoder
              end
              encoder.begin_group kind
              state = patterns::StringState.new kind, interpreted, self[2]
              encoder.text_token match, :delimiter

            elsif value_expected and match = scan(/#{patterns::CHARACTER}/o)
              value_expected = false
              encoder.text_token match, :integer

            elsif match = scan(/ [\/%]=? | <(?:<|=>?)? | [?:;] /x)
              value_expected = true
              encoder.text_token match, :operator

            elsif match = scan(/`/)
              if method_call_expected
                encoder.text_token match, :operator
                value_expected = true
              else
                encoder.begin_group :shell
                encoder.text_token match, :delimiter
                state = patterns::StringState.new :shell, true, match
              end

            elsif match = scan(unicode ? /#{patterns::GLOBAL_VARIABLE}/uo :
                                         /#{patterns::GLOBAL_VARIABLE}/o)
              encoder.text_token match, :global_variable
              value_expected = false

            elsif match = scan(unicode ? /#{patterns::CLASS_VARIABLE}/uo :
                                         /#{patterns::CLASS_VARIABLE}/o)
              encoder.text_token match, :class_variable
              value_expected = false

            elsif match = scan(/\\\z/)
              encoder.text_token match, :space

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
              
              encoder.text_token getch, :error
              
            end
            
            if last_state
              state = last_state
              last_state = nil
            end

          elsif state == :def_expected
            if match = scan(unicode ? /(?>#{patterns::METHOD_NAME_EX})(?!\.|::)/uo :
                                      /(?>#{patterns::METHOD_NAME_EX})(?!\.|::)/o)
              encoder.text_token match, :method
              state = :initial
            else
              last_state = :dot_expected
              state = :initial
            end

          elsif state == :dot_expected
            if match = scan(/\.|::/)
              # invalid definition
              state = :def_expected
              encoder.text_token match, :operator
            else
              state = :initial
            end

          elsif state == :module_expected
            if match = scan(/<</)
              encoder.text_token match, :operator
            else
              state = :initial
              if match = scan(unicode ? / (?:#{patterns::IDENT}::)* #{patterns::IDENT} /oux :
                                        / (?:#{patterns::IDENT}::)* #{patterns::IDENT} /ox)
                encoder.text_token match, :class
              end
            end

          elsif state == :undef_expected
            state = :undef_comma_expected
            if match = scan(unicode ? /(?>#{patterns::METHOD_NAME_EX})(?!\.|::)/uo :
                                      /(?>#{patterns::METHOD_NAME_EX})(?!\.|::)/o)
              encoder.text_token match, :method
            elsif match = scan(/#{patterns::SYMBOL}/o)
              case delim = match[1]
              when ?', ?"
                encoder.begin_group :symbol
                encoder.text_token ':', :symbol
                match = delim.chr
                encoder.text_token match, :delimiter
                state = patterns::StringState.new :symbol, delim == ?", match
                state.next_state = :undef_comma_expected
              else
                encoder.text_token match, :symbol
              end
            else
              state = :initial
            end

          elsif state == :undef_comma_expected
            if match = scan(/,/)
              encoder.text_token match, :operator
              state = :undef_expected
            else
              state = :initial
            end

          elsif state == :alias_expected
            match = scan(unicode ? /(#{patterns::METHOD_NAME_OR_SYMBOL})([ \t]+)(#{patterns::METHOD_NAME_OR_SYMBOL})/uo :
                                   /(#{patterns::METHOD_NAME_OR_SYMBOL})([ \t]+)(#{patterns::METHOD_NAME_OR_SYMBOL})/o)
            
            if match
              encoder.text_token self[1], (self[1][0] == ?: ? :symbol : :method)
              encoder.text_token self[2], :space
              encoder.text_token self[3], (self[3][0] == ?: ? :symbol : :method)
            end
            state = :initial

          else
            raise_inspect 'Unknown state: %p' % [state], encoder
          end
          
        end
      end

      # cleaning up
      if options[:keep_state]
        @state = state
      end
      if state.is_a? patterns::StringState
        encoder.end_group state.type
      end
      if inline_block_stack
        until inline_block_stack.empty?
          state, *more = inline_block_stack.pop
          encoder.end_group :inline if more
          encoder.end_group state.type
        end
      end

      encoder
    end

  end

end
end
