module CodeRay
  module Scanners
    class RuleBasedScanner < Scanner
      
      Groups = Struct.new :token_kinds
      Kind = Struct.new :token_kind
      Push = Struct.new :state
      Pop = Class.new
      PushState = Struct.new :state
      PopState = Class.new
      Check = Struct.new :condition
      CheckIf = Class.new Check
      CheckUnless = Class.new Check
      ValueSetter = Struct.new :targets, :value
      Continue = Class.new
      
      class << self
        attr_accessor :states
        
        def state *names, &block
          @code ||= ""
          
          @code << "when #{names.map(&:inspect).join(', ')}\n"
          
          @first = true
          instance_eval(&block)
          @code << "  else\n"
          # @code << "    raise 'no match for #{names.map(&:inspect).join(', ')}'\n"
          @code << "    encoder.text_token getch, :error\n"
          @code << "  end\n"
          @code << "  \n"
        end
        
        def on? pattern
          pattern_expression = pattern.inspect
          @code << "  #{'els' unless @first}if check(#{pattern_expression})\n"
          
          @first = true
          yield
          @code << "  end\n"
          
          @first = false
        end
        
        def on *pattern_and_actions
          if index = pattern_and_actions.find_index { |item| !item.is_a?(Check) }
            preconditions = pattern_and_actions[0..index - 1] if index > 0
            pattern       = pattern_and_actions[index]         or raise 'I need a pattern!'
            actions       = pattern_and_actions[index + 1..-1] or raise 'I need actions!'
          end
          
          precondition_expression = ''
          if preconditions
            for precondition in preconditions
              case precondition
              when CheckIf
                case precondition.condition
                when Proc
                  precondition_expression << "#{make_callback(precondition.condition)} && "
                when Symbol
                  precondition_expression << "#{precondition.condition} && "
                else
                  raise "I don't know how to evaluate this check_if precondition: %p" % [precondition.condition]
                end
              when CheckUnless
                case precondition.condition
                when Proc
                  precondition_expression << "!#{make_callback(precondition.condition)} && "
                when Symbol
                  precondition_expression << "!#{precondition.condition} && "
                else
                  raise "I don't know how to evaluate this check_unless precondition: %p" % [precondition.condition]
                end
              else
                raise "I don't know how to evaluate this precondition: %p" % [precondition]
              end
            end
          end
          
          case pattern
          when String
            raise
            pattern_expression = pattern
          when Regexp
            pattern_expression = pattern.inspect
          when Proc
            pattern_expression = make_callback(pattern)
          else
            raise "I don't know how to evaluate this pattern: %p" % [pattern]
          end
          
          @code << "  #{'els' unless @first}if #{precondition_expression}match = scan(#{pattern_expression})\n"
          
          for action in actions
            case action
            when String
              raise
              @code << "    p 'evaluate #{action.inspect}'\n" if $DEBUG
              @code << "    #{action}\n"
              
            when Symbol
              @code << "    p 'text_token %p %p' % [match, #{action.inspect}]\n" if $DEBUG
              @code << "    encoder.text_token match, #{action.inspect}\n"
            when Kind
              case action.token_kind
              when Proc
                @code << "    encoder.text_token match, kind = #{make_callback(action.token_kind)}\n"
              else
                raise "I don't know how to evaluate this kind: %p" % [action.token_kind]
              end
            when Groups
              @code << "    p 'text_tokens %p in groups %p' % [match, #{action.token_kinds.inspect}]\n" if $DEBUG
              action.token_kinds.each_with_index do |kind, i|
                @code << "    encoder.text_token self[#{i + 1}], #{kind.inspect} if self[#{i + 1}]\n"
              end
            
            when Push, PushState
              case action.state
              when String
                raise
                @code << "    p 'push %p' % [#{action.state}]\n" if $DEBUG
                @code << "    state = #{action.state}\n"
              when Symbol
                @code << "    p 'push %p' % [#{action.state.inspect}]\n" if $DEBUG
                @code << "    state = #{action.state.inspect}\n"
              when Proc
                @code << "    state = #{make_callback(action.state)}\n"
              else
                raise "I don't know how to evaluate this push state: %p" % [action.state]
              end
              @code << "    states << state\n"
              @code << "    encoder.begin_group state\n" if action.is_a? Push
            when Pop, PopState
              @code << "    p 'pop %p' % [states.last]\n" if $DEBUG
              if action.is_a? Pop
                @code << "    encoder.end_group states.pop\n"
              else
                @code << "    states.pop\n"
              end
              @code << "    state = states.last\n"
            
            when ValueSetter
              case action.value
              when Proc
                @code << "    #{action.targets.join(' = ')} = #{make_callback(action.value)}\n"
              when Symbol
                @code << "    #{action.targets.join(' = ')} = #{action.value}\n"
              else
                @code << "    #{action.targets.join(' = ')} = #{action.value.inspect}\n"
              end
            
            when Proc
              @code << "    #{make_callback(action)}\n"
              
            when Continue
              @code << "    next\n"
              
            else
              raise "I don't know how to evaluate this action: %p" % [action]
            end
          end
          
          @first = false
        end
        
        def groups *token_kinds
          Groups.new token_kinds
        end
        
        def kind token_kind = nil, &block
          Kind.new token_kind || block
        end
        
        def push state = nil, &block
          raise 'push requires a state or a block; got nothing' unless state || block
          Push.new state || block
        end
        
        def pop
          Pop.new
        end
        
        def push_state state = nil, &block
          raise 'push_state requires a state or a block; got nothing' unless state || block
          PushState.new state || block
        end
        
        def pop_state
          PopState.new
        end
        
        def check_if value = nil, &callback
          CheckIf.new value || callback
        end
        
        def check_unless value = nil, &callback
          CheckUnless.new value || callback
        end
        
        def flag_on *flags
          ValueSetter.new Array(flags), true
        end
        
        def flag_off *flags
          ValueSetter.new Array(flags), false
        end
        
        def set flag, value = nil, &callback
          ValueSetter.new [flag], value || callback
        end
        
        def unset *flags
          ValueSetter.new Array(flags), nil
        end
        
        def continue
          Continue.new
        end
        
        protected
        
        def make_callback block
          @callbacks ||= {}
          
          base_name = "__callback_line_#{block.source_location.last}"
          name = base_name
          counter = 'a'
          while @callbacks.key?(name)
            name = "#{base_name}_#{counter}"
            counter.succ!
          end
          
          @callbacks[name] = define_method(name, &block)
          
          arguments = block.parameters.map(&:last)
          
          if arguments.empty?
            name
          else
            "#{name}(#{arguments.join(', ')})"
          end
        end
      end
    end
  end
end