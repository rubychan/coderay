require 'set'

module CodeRay
  module Scanners
    module SimpleScannerDSL
      Pattern = Struct.new :pattern
      Groups = Struct.new :token_kinds
      Kind = Struct.new :token_kind
      Push = Struct.new :state, :group
      Pop = Struct.new :group
      PushState = Struct.new :state
      PopState = Class.new
      Check = Struct.new :condition
      CheckIf = Class.new Check
      CheckUnless = Class.new Check
      ValueSetter = Struct.new :targets, :value
      Increment = Struct.new :targets, :operation, :value
      Continue = Class.new

      State = Struct.new :names, :block, :dsl do
        def initialize(*)
          super
          eval
        end

        def eval
          @first = true

          @code = ""
          instance_eval(&block)
        end

        def code
          <<-RUBY
when #{names.map(&:inspect).join(', ')}
#{ rules_code.chomp.gsub(/^/, '  ') }
  else
#{ handle_unexpected_char_code.chomp.gsub(/^/, '  ' * 2) }
  end
          RUBY
        end

        protected

        def rules_code
          @code
        end

        def handle_unexpected_char_code
          ''.tap do |code|
            code << 'puts "no match for #{state.inspect} => skip char"' << "\n" if $DEBUG
            code << 'encoder.text_token getch, :error'
          end
        end

        public

        def on? pattern
          pattern_expression = pattern.inspect
          @code << "#{'els' unless @first}if check(#{pattern_expression})\n"

          @first = true
          yield
          @code << "end\n"

          @first = false
        end

        def on *pattern_and_actions
          if index = pattern_and_actions.find_index { |item| !(item.is_a?(Check) || item.is_a?(Regexp) || item.is_a?(Pattern)) }
            conditions = pattern_and_actions[0..index - 1] or raise 'I need conditions or a pattern!'
            actions    = pattern_and_actions[index..-1]    or raise 'I need actions!'
          else
            raise "invalid rule structure: #{pattern_and_actions.map(&:class)}"
          end

          condition_expressions = []
          if conditions
            for condition in conditions
              case condition
              when CheckIf
                case condition.condition
                when Proc
                  condition_expressions << "#{dsl.add_callback(condition.condition)}"
                when Symbol
                  condition_expressions << "#{condition.condition}"
                else
                  raise "I don't know how to evaluate this check_if condition: %p" % [condition.condition]
                end
              when CheckUnless
                case condition.condition
                when Proc
                  condition_expressions << "!#{dsl.add_callback(condition.condition)}"
                when Symbol
                  condition_expressions << "!#{condition.condition}"
                else
                  raise "I don't know how to evaluate this check_unless condition: %p" % [condition.condition]
                end
              when Pattern
                case condition.pattern
                when Proc
                  condition_expressions << "match = scan(#{dsl.add_callback(condition.pattern)})"
                else
                  raise "I don't know how to evaluate this pattern: %p" % [condition.pattern]
                end
              when Regexp
                condition_expressions << "match = scan(#{condition.inspect})"
              else
                raise "I don't know how to evaluate this pattern/condition: %p" % [condition]
              end
            end
          end

          @code << "#{'els' unless @first}if #{condition_expressions.join(' && ')}\n"

          for action in actions
            case action
            when String
              raise
              @code << "p 'evaluate #{action.inspect}'\n" if $DEBUG
              @code << "#{action}\n"

            when Symbol
              @code << "p 'text_token %p %p' % [match, #{action.inspect}]\n" if $DEBUG
              @code << "encoder.text_token match, #{action.inspect}\n"
            when Kind
              case action.token_kind
              when Proc
                @code << "encoder.text_token match, kind = #{dsl.add_callback(action.token_kind)}\n"
              else
                raise "I don't know how to evaluate this kind: %p" % [action.token_kind]
              end
            when Groups
              @code << "p 'text_tokens %p in groups %p' % [match, #{action.token_kinds.inspect}]\n" if $DEBUG
              action.token_kinds.each_with_index do |kind, i|
                @code << "encoder.text_token self[#{i + 1}], #{kind.inspect} if self[#{i + 1}]\n"
              end

            when Push, PushState
              case action.state
              when String
                raise
                @code << "p 'push %p' % [#{action.state}]\n" if $DEBUG
                @code << "state = #{action.state}\n"
                @code << "states << state\n"
              when Symbol
                @code << "p 'push %p' % [#{action.state.inspect}]\n" if $DEBUG
                @code << "state = #{action.state.inspect}\n"
                @code << "states << state\n"
              when Proc
                @code << "if new_state = #{dsl.add_callback(action.state)}\n"
                @code << "  state = new_state\n"
                @code << "  states << new_state\n"
                @code << "end\n"
              else
                raise "I don't know how to evaluate this push state: %p" % [action.state]
              end
              if action.is_a? Push
                if action.state == action.group
                  @code << "encoder.begin_group state\n"
                else
                  case action.state
                  when Symbol
                    @code << "p 'begin group %p' % [#{action.group.inspect}]\n" if $DEBUG
                    @code << "encoder.begin_group #{action.group.inspect}\n"
                  when Proc
                    @code << "encoder.begin_group #{dsl.add_callback(action.group)}\n"
                  else
                    raise "I don't know how to evaluate this push state: %p" % [action.state]
                  end
                end
              end
            when Pop, PopState
              @code << "p 'pop %p' % [states.last]\n" if $DEBUG
              if action.is_a? Pop
                if action.group
                  case action.group
                  when Symbol
                    @code << "encoder.end_group #{action.group.inspect}\n"
                  else
                    raise "I don't know how to evaluate this pop group: %p" % [action.group]
                  end
                  @code << "states.pop\n"
                else
                  @code << "encoder.end_group states.pop\n"
                end
              else
                @code << "states.pop\n"
              end
              @code << "state = states.last\n"

            when ValueSetter
              case action.value
              when Proc
                @code << "#{action.targets.join(' = ')} = #{dsl.add_callback(action.value)}\n"
              when Symbol
                @code << "#{action.targets.join(' = ')} = #{action.value}\n"
              else
                @code << "#{action.targets.join(' = ')} = #{action.value.inspect}\n"
              end

            when Increment
              case action.value
              when Proc
                @code << "#{action.targets.join(' = ')} #{action.operation}= #{dsl.add_callback(action.value)}\n"
              when Symbol
                @code << "#{action.targets.join(' = ')} #{action.operation}= #{action.value}\n"
              else
                @code << "#{action.targets.join(' = ')} #{action.operation}= #{action.value.inspect}\n"
              end

            when Proc
              @code << "#{dsl.add_callback(action)}\n"

            when Continue
              @code << "next\n"

            else
              raise "I don't know how to evaluate this action: %p" % [action]
            end
          end

          @first = false
        end

        def groups *token_kinds
          Groups.new token_kinds
        end

        def pattern pattern = nil, &block
          Pattern.new pattern || block
        end

        def kind token_kind = nil, &block
          Kind.new token_kind || block
        end

        def push state = nil, group = state, &block
          raise 'push requires a state or a block; got nothing' unless state || block
          Push.new state || block, group || block
        end

        def pop group = nil
          Pop.new group
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
          flags.each { |name| dsl.add_variable name }
          ValueSetter.new Array(flags), true
        end

        def flag_off *flags
          flags.each { |name| dsl.add_variable name }
          ValueSetter.new Array(flags), false
        end

        def set flag, value = nil, &callback
          dsl.add_variable flag
          ValueSetter.new [flag], value || callback
        end

        def unset *flags
          flags.each { |name| dsl.add_variable name }
          ValueSetter.new Array(flags), nil
        end

        def increment *counters
          counters.each { |name| dsl.add_variable name }
          Increment.new Array(counters), :+, 1
        end

        def decrement *counters
          counters.each { |name| dsl.add_variable name }
          Increment.new Array(counters), :-, 1
        end

        def continue
          Continue.new
        end
      end

      attr_accessor :states

      def state *names, &block
        @states ||= []
        @states << State.new(names, block, self)
      end

      def add_callback block
        base_name = "__callback_line_#{block.source_location.last}"
        callback_name = base_name
        counter = 'a'
        while callbacks.key?(callback_name)
          callback_name = "#{base_name}_#{counter}"
          counter.succ!
        end

        callbacks[callback_name] = define_method(callback_name, &block)

        parameters = block.parameters

        if parameters.empty?
          callback_name
        else
          parameter_names = parameters.map(&:last)
          parameter_names.each { |name| variables << name }
          "#{callback_name}(#{parameter_names.join(', ')})"
        end
      end

      def add_variable name
        variables << name
      end

      protected

      def callbacks
        @callbacks ||= {}
      end

      def variables
        @variables ||= Set.new
      end

      def additional_variables
        variables - %i(encoder options state states match kind)
      end

      def scan_tokens_code
        <<-"RUBY"
state = options[:state] || @state
states = [state]
#{ restore_local_variables_code.chomp }

until eos?
  case state
#{ states_code.chomp.gsub(/^/, '  ') }
  else
    raise_inspect 'Unknown state: %p' % [state], encoder
  end
end

@state = state if options[:keep_state]

#{ close_groups_code.chomp }

encoder
        RUBY
      end

      def restore_local_variables_code
        additional_variables.sort.map { |name| "#{name} = @#{name}" }.join("\n")
      end

      def states_code
        @states.map(&:code)[0,1].join
      end

      def close_groups_code
        'close_groups(encoder, states)'
      end
    end
  end
end