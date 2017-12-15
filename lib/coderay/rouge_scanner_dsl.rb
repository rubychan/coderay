require 'set'

module CodeRay
  module Scanners
    module RougeScannerDSL
      NoStatesError = Class.new StandardError

      State = Struct.new :name, :rules do
        def initialize(name, &block)
          super name, []

          instance_eval(&block)
        end

        def code scanner
          <<-RUBY
when #{name.inspect}
#{ rules_code(scanner).chomp.gsub(/^/, '  ') }
  else
    encoder.text_token getch, :error
  end
          RUBY
        end

        def rules_code scanner, first: true
          raise 'no rules defined for %p' % [self] if rules.empty?

          [
            rules.first.code(scanner, first: first),
            *rules.drop(1).map { |rule| rule.code(scanner) }
          ].join
        end

        protected

        # DSL

        def rule pattern, token = nil, next_state = nil, &block
          unless token || block
            raise 'please pass `rule` a token to yield or a callback'
          end

          case token
          when Class
            unless token < Rouge::Token
              raise "invalid token: #{token.inspect}"
            end

            case next_state
            when Symbol
              rules << Rule.new(pattern, token, next_state)
            when nil
              rules << Rule.new(pattern, token)
            else
              raise "invalid next state: #{next_state.inspect}"
            end
          when nil
            rules << CallbackRule.new(pattern, block)
          else
            raise "invalid token: #{token.inspect}"
          end
        end

        def mixin state_name
          rules << Mixin.new(state_name)
        end
      end

      Rule = Struct.new :pattern, :token, :action do
        def initialize(pattern, token, action = nil)
          super
        end

        def code scanner, first: false
          <<-RUBY + action_code.to_s
#{'els' unless first}if match = scan(#{pattern.inspect})
  encoder.text_token match, #{token.token_chain.map(&:name).join('::')}
          RUBY
        end

        def action_code
          case action
          when :pop!
            <<-RUBY
  states.pop
  state = states.last
            RUBY
          when Symbol
            <<-RUBY
  state = #{action.inspect}
  states << state
            RUBY
          end
        end
      end

      CallbackRule = Struct.new :pattern, :callback do
        def code scanner, first: false
          <<-RUBY
#{'els' unless first}if match = scan(#{pattern.inspect})
  @match = match
  #{scanner.add_callback(callback)}
          RUBY
        end
      end

      Mixin = Struct.new(:state_name) do
        def code scanner, first: false
          scanner.states[state_name].rules_code(scanner, first: first)
        end
      end

      attr_accessor :states

      def state name, &block
        @states ||= {}
        @states[name] = State.new(name, &block)
      end

      def add_callback block
        base_name = "__callback_line_#{block.source_location.last}"
        callback_name = base_name
        counter = 'a'
        while callbacks.key?(callback_name)
          callback_name = "#{base_name}_#{counter}"
          counter = counter.succ
        end

        callbacks[callback_name] = define_method(callback_name, &block)

        parameters = block.parameters

        if parameters.empty?
          callback_name
        else
          parameter_names = parameters.map do |type, name|
            raise "callbacks don't allow rest parameters: %p" % [parameters] unless type == :req || type == :opt
            name = :match if name == :m
            name
          end

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
#{ restore_local_variables_code }
until eos?
  case state
#{ states_code.chomp.gsub(/^/, '  ') }
  else
    raise_inspect 'Unknown state: %p' % [state], encoder
  end
end

@state = state if options[:keep_state]

close_groups(encoder, states)

encoder
        RUBY
      end

      def restore_local_variables_code
        additional_variables.sort.map { |name| "#{name} = @#{name}" }.join("\n")
      end

      def states_code
        unless defined?(@states) && !@states.empty?
          raise NoStatesError, 'no states defined for %p' % [self.class]
        end

        @states.values.map { |state| state.code(self) }.join
      end
    end
  end
end