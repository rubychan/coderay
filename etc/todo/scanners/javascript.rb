module CodeRay
module Scanners

  # Basic Javascript scanner
  class Javascript < Scanner

    include Streamable

    register_for :javascript

    helper :patterns

    DEFAULT_OPTIONS = {
    }

  private
    def scan_tokens tokens, options
      first_bake = saved_tokens = nil
      last_token_dot = false
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
            tokens << [:close, state.type]
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
              inline_block_stack << [state, depth]
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

          else
            raise_inspect 'else-case " reached; %p not handled, state = %p' % [match, state], tokens

          end
          next
# }}}
        else
# {{{
          if match = scan(/ [ \t\f]+ | \\? \n | \# .* /x) 
            case m = match[0]
            when ?\s, ?\t, ?\f
              match << scan(/\s*/) unless eos?
              kind = :space
            when ?\n, ?\\
              kind = :space
              match << scan(/\s*/) unless eos?
            when ?#, ?=, ?_
              kind = :comment
            else
              raise_inspect 'else-case _ reached, because case %p was not handled' % [matched[0].chr], tokens
            end
            tokens << [match, kind]
            next

          elsif state == :initial

            # IDENTS #
            if match = scan(/#{patterns::METHOD_NAME}/o)
              kind = last_token_dot ? :ident :
                                      patterns::IDENT_KIND[match]

            # OPERATORS #
            elsif (not last_token_dot and match = scan(/ ==?=? | \.\.?\.? | [\(\)\[\]\{\}] | :: | , /x)) or
              (last_token_dot and match = scan(/#{patterns::METHOD_NAME_OPERATOR}/o))
              last_token_dot = :set if match == '.' or match == '::'
              kind = :operator
              unless inline_block_stack.empty?
                case match
                when '{'
                  depth += 1
                when '}'
                  depth -= 1
                  if depth == 0  # closing brace of inline block reached
                    state, depth = inline_block_stack.pop
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

            elsif match = scan(/#{patterns::NUMERIC}/o)
              kind = if self[1] then :float else :integer end

            elsif match = scan(/ \+\+ | -- | << | >> /x)
              kind = :operator

            elsif match = scan(/ [-+!~^]=? | [*|&]{1,2}=? | >>? /x)
              kind = :operator

            elsif match = scan(/ [\/%]=? | <(?:<|=>?)? | [?:;] /x)
              kind = :operator

            else
              kind = :error
              match = getch

            end

          end
# }}}

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
