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
  class Ruby < Scanner

    include Streamable

    register_for :ruby

    helper :patterns

    DEFAULT_OPTIONS = {
      :parse_regexps => true,
    }

  private
    def scan_tokens tokens, options
      parse_regexp = false # options[:parse_regexps]
      first_bake = saved_tokens = nil
      last_token_dot = false
      fancy_allowed = regexp_allowed = true
      heredocs = nil
      last_state = nil
      state = :initial
      depth = nil
      inline_block_stack = []

      patterns = Patterns  # avoid constant lookup

      until eos?
        match = nil
        kind = nil

        if state.instance_of? patterns::StringState
# {{{
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
            if state.paren
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
              if parse_regexp
                extended = modifiers.index ?x
                tokens = saved_tokens
                regexp = tokens
                for text, kind in regexp
                  if text.is_a? ::String
                    case kind
                    when :content
                      text.scan(/([^#]+)|(#.*)/) do |plain, comment|
                        if plain
                          tokens << [plain, :content]
                        else
                          tokens << [comment, :comment]
                        end
                      end
                    when :character
                      if text[/\\(?:[swdSWDAzZbB]|\d+)/]
                        tokens << [text, :modifier]
                      else
                        tokens << [text, kind]
                      end
                    else
                      tokens << [text, kind]
                    end
                  else
                    tokens << [text, kind]
                  end
                end
                first_bake = saved_tokens = nil
              end
            end
            tokens << [:close, state.type]
            fancy_allowed = regexp_allowed = false
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
            case peek(1)[0]
            when ?{
              inline_block_stack << [state, depth, heredocs]
              fancy_allowed = regexp_allowed = true
              state = :initial
              depth = 1
              tokens << [:open, :inline]
              tokens << [match + getch, :delimiter]
            when ?$, ?@
              tokens << [match, :escape]
              last_state = state  # scan one token as normal code, then return here
              state = :initial
            else
              raise_inspect 'else-case # reached; #%p not handled' % peek(1), tokens
            end

          when state.paren
            state.paren_depth += 1
            tokens << [match, :nesting_delimiter]

          when /#{patterns::REGEXP_SYMBOLS}/ox
            tokens << [match, :function]

          else
            raise_inspect 'else-case " reached; %p not handled, state = %p' % [match, state], tokens

          end
          next
# }}}
        else
# {{{
          if match = scan(/ [ \t\f]+ | \\? \n | \# .* /x) or
            ( bol? and match = scan(/#{patterns::RUBYDOC_OR_DATA}/o) )
            fancy_allowed = true
            case m = match[0]
            when ?\s, ?\t, ?\f
              match << scan(/\s*/) unless eos? or heredocs
              kind = :space
            when ?\n, ?\\
              kind = :space
              if m == ?\n
                regexp_allowed = true
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
            when ?#, ?=, ?_
              kind = :comment
              regexp_allowed = true
            else
              raise_inspect 'else-case _ reached, because case %p was not handled' % [matched[0].chr], tokens
            end
            tokens << [match, kind]
            next

          elsif state == :initial

            # IDENTS #
            if match = scan(/#{patterns::METHOD_NAME}/o)
              if last_token_dot
                kind = if match[/^[A-Z]/] and not match?(/\(/) then :constant else :ident end
              else
                kind = patterns::IDENT_KIND[match]
                if kind == :ident and match[/^[A-Z]/] and not match[/[!?]$/] and not match?(/\(/)
                  kind = :constant
                elsif kind == :reserved
                  state = patterns::DEF_NEW_STATE[match]
                end
              end
              ## experimental!
              fancy_allowed = regexp_allowed = :set if patterns::REGEXP_ALLOWED[match] or check(/\s+(?:%\S|\/\S)/)

            # OPERATORS #
            elsif (not last_token_dot and match = scan(/ ==?=? | \.\.?\.? | [\(\)\[\]\{\}] | :: | , /x)) or
              (last_token_dot and match = scan(/#{patterns::METHOD_NAME_OPERATOR}/o))
              if match !~ / [.\)\]\}] /x or match =~ /\.\.\.?/
                regexp_allowed = fancy_allowed = :set
              end
              last_token_dot = :set if match == '.' or match == '::'
              kind = :operator
              unless inline_block_stack.empty?
                case match
                when '{'
                  depth += 1
                when '}'
                  depth -= 1
                  if depth == 0  # closing brace of inline block reached
                    state, depth, heredocs = inline_block_stack.pop
                    tokens << [match, :delimiter]
                    kind = :inline
                    match = :close
                  end
                end
              end

            elsif match = scan(/ ['"] /mx)
              tokens << [:open, :string]
              kind = :delimiter
              state = patterns::StringState.new :string, match == '"', match  # important for streaming

            elsif match = scan(/#{patterns::INSTANCE_VARIABLE}/o)
              kind = :instance_variable

            elsif regexp_allowed and match = scan(/\//)
              tokens << [:open, :regexp]
              kind = :delimiter
              interpreted = true
              state = patterns::StringState.new :regexp, interpreted, match
              if parse_regexp
                tokens = []
                saved_tokens = tokens
              end

            elsif match = scan(/#{patterns::NUMERIC}/o)
              kind = if self[1] then :float else :integer end

            elsif match = scan(/#{patterns::SYMBOL}/o)
              case delim = match[1]
              when ?', ?"
                tokens << [:open, :symbol]
                tokens << [':', :symbol]
                match = delim.chr
                kind = :delimiter
                state = patterns::StringState.new :symbol, delim == ?", match
              else
                kind = :symbol
              end

            elsif match = scan(/ [-+!~^]=? | [*|&]{1,2}=? | >>? /x)
              regexp_allowed = fancy_allowed = :set
              kind = :operator

            elsif fancy_allowed and match = scan(/#{patterns::HEREDOC_OPEN}/o)
              indented = self[1] == '-'
              quote = self[3]
              delim = self[quote ? 4 : 2]
              kind = patterns::QUOTE_TO_TYPE[quote]
              tokens << [:open, kind]
              tokens << [match, :delimiter]
              match = :close
              heredoc = patterns::StringState.new kind, quote != '\'', delim, (indented ? :indented : :linestart )
              heredocs ||= []  # create heredocs if empty
              heredocs << heredoc

            elsif fancy_allowed and match = scan(/#{patterns::FANCY_START_SAVE}/o)
              kind, interpreted = *patterns::FancyStringType.fetch(self[1]) do
                raise_inspect 'Unknown fancy string: %%%p' % k, tokens
              end
              tokens << [:open, kind]
              state = patterns::StringState.new kind, interpreted, self[2]
              kind = :delimiter

            elsif fancy_allowed and match = scan(/#{patterns::CHARACTER}/o)
              kind = :integer

            elsif match = scan(/ [\/%]=? | <(?:<|=>?)? | [?:;] /x)
              regexp_allowed = fancy_allowed = :set
              kind = :operator

            elsif match = scan(/`/)
              if last_token_dot
                kind = :operator
              else
                tokens << [:open, :shell]
                kind = :delimiter
                state = patterns::StringState.new :shell, true, match
              end

            elsif match = scan(/#{patterns::GLOBAL_VARIABLE}/o)
              kind = :global_variable

            elsif match = scan(/#{patterns::CLASS_VARIABLE}/o)
              kind = :class_variable

            else
              kind = :error
              match = getch

            end

          elsif state == :def_expected
            state = :initial
            if match = scan(/(?>#{patterns::METHOD_NAME_EX})(?!\.|::)/o)
              kind = :method
            else
              next
            end

          elsif state == :undef_expected
            state = :undef_comma_expected
            if match = scan(/#{patterns::METHOD_NAME_EX}/o)
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

          elsif state == :module_expected
            if match = scan(/<</)
              kind = :operator
            else
              state = :initial
              if match = scan(/ (?:#{patterns::IDENT}::)* #{patterns::IDENT} /ox)
                kind = :class
              else
                next
              end
            end

          end
# }}}

          regexp_allowed = regexp_allowed == :set
          fancy_allowed = fancy_allowed == :set
          last_token_dot = last_token_dot == :set

          if $DEBUG and not kind
            raise_inspect 'Error token %p in line %d' %
              [[match, kind], line], tokens, state
          end
          raise_inspect 'Empty token', tokens unless match

          tokens << [match, kind]

          if last_state
            state = last_state
            last_state = nil
          end
        end
      end

      inline_block_stack << [state] if state.is_a? patterns::StringState
      until inline_block_stack.empty?
        this_block = inline_block_stack.pop
        tokens << [:close, :inline] if this_block.size > 1
        state = this_block.first
        tokens << [:close, state.type]
      end

      tokens
    end

  end

end
end

# vim:fdm=marker
