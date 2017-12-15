require 'set'

module CodeRay
  module Scanners
    class StateBasedScanner < Scanner
      class State
        attr_reader :names
        attr_reader :rules
        attr_reader :scanner

        def initialize scanner, names, &block
          @scanner = scanner
          @names = names

          @rules = []
          @check = nil

          instance_eval(&block)
        end

        def rules_code
          <<-RUBY
when #{names.map(&:inspect).join(', ')}
#{rules.map.with_index { |rule, index| rule.code(first: index.zero?) }.join}
  else
    puts "no match for \#{state.inspect} => skip character" if $DEBUG
    encoder.text_token getch, :error
  end

          RUBY
        end

        protected

        # structure
        def check *conditions, &block
          return @check unless conditions.any? || block
          raise "Can't nest check yet" if @check

          @check = Conditions.new(conditions)
          instance_eval(&block)
          @check = nil
        end

        # rules
        def on pattern, *actions, &block
          @rules << Rule.new(self, pattern, *actions, check: @check, &block)
        end

        def skip pattern, *actions, &block
          @rules << Rule.new(self, pattern, *actions, check: @check, skip: true, &block)
        end

        def otherwise *actions, &block
          @rules << Rule.new(self, //, *actions, check: @check, skip: true, &block)
        end

        # actions
        def push state
          Push.new(state)
        end

        def pop
          Pop.new
        end

        def kind token_kind = nil, &block
          Kind.new token_kind || scanner.callback(block)
        end

        def groups *token_kinds
          Groups.new(token_kinds)
        end

        def set target, value = nil, &block
          Setter.new target, value || block || true
        end

        def callback block
          scanner.callback(block)
        end

        # magic flag getters
        def method_missing method, *args, &block
          method_name = method.to_s
          if method_name.end_with?('?')
            Getter.new(scanner.variable(method_name.chomp('?')))
          else
            super
          end
        end
      end

      class GroupState < State
      end

      class Rule
        attr_reader :pattern
        attr_reader :actions
        attr_reader :check
        attr_reader :state

        def initialize state, pattern, *actions, check:, skip: false, &block
          @state = state
          @pattern = (skip ? Skip : Scan).new(pattern)
          @actions = *build_actions(actions, block)
          @check = check

          raise [pattern, *actions, check, skip, block].inspect if check == false
        end

        def code first:
          <<-RUBI
  #{'els' unless first}if #{condition_expression}
#{actions_code.gsub(/^/, '  ' * 2)}
          RUBI
        end

        def skip?
          @pattern.is_a?(Skip)
        end

        protected

        def condition_expression
          [check, pattern].compact.map(&:code).join(' && ')
        end

        def actions_code
          actions.map(&:code).join("\n")
        end

        def build_actions actions, block
          actions += [block] if block

          actions.map do |action|
            case action
            when Symbol
              Token.new(action)
            when Proc
              state.instance_eval do
                callback action
              end
            when WordList
              state.instance_eval do
                kind { |match| action[match] }
              end
            when Push, Pop, Groups, Kind, Setter
              action
            else
              raise "Don't know how to build action for %p (%p)" % [action, action.class]
            end
          end
        end
      end

      # conditions
      class Conditions < Struct.new(:conditions)
        def code
          "#{conditions.map(&:code).join(' && ')}"
        end
      end

      class Scan < Struct.new(:pattern)
        def code
          "match = scan(#{pattern.inspect})"
        end
      end

      class Skip < Scan
      end

      class Getter < Struct.new(:name, :negative)
        def code
          "#{negative && '!'}#{name}"
        end

        def !@
          negative
        end

        protected

        def negative
          @negative ||= Getter.new(name, :negative)
        end
      end
      
      # actions
      class Push < Struct.new :state
        def code
          "push"
        end
      end

      class Pop < Class.new
        def code
          "pop"
        end
      end

      class Groups < Struct.new(:token_kinds)
        def code
          "groups"
        end
      end

      class Setter < Struct.new(:name, :value)
        def code
          "set"
        end
      end


      class Kind < Struct.new(:token_kind)
        def code
          case token_kind
          when Callback
            "encoder.text_token match, kind = #{token_kind.code}\n"
          else
            raise "I don't know how to evaluate this kind: %p" % [token_kind]
          end
        end
      end

      class Token < Struct.new(:name)
        def code
          "encoder.text_token match, #{name.inspect}"
        end
      end

      class Callback < Struct.new(:name, :block)
        def code
          if parameter_names.empty?
            name
          else
            "#{name}(#{parameter_names.join(', ')})"
          end
        end

        protected

        def parameter_names
          block.parameters.map(&:last)
        end
      end

      class << self
        def states
          @states ||= {}
        end

        def scan_tokens tokens, options
          self.class.define_scan_tokens!

          scan_tokens tokens, options
        end

        def define_scan_tokens!
          if ENV['PUTS']
            puts CodeRay.scan(scan_tokens_code, :ruby).terminal
            puts "callbacks: #{callbacks.size}"
          end
          
          class_eval scan_tokens_code
        end

        def variable name
          variables << name.to_sym

          name
        end

        def callback block
          return unless block

          callback_name = name_for_callback(block)
          callbacks[callback_name] = define_method(callback_name, &block)
          block.parameters.map(&:last).each { |name| variable name }

          Callback.new(callback_name, block)
        end

        protected

        def state *names, state_class: State, &block
          state_class.new(self, names, &block).tap do |state|
            for name in names
              states[name] = state
            end
          end
        end

        def group_state *names, &block
          state(*names, state_class: GroupState, &block)
        end

        def callbacks
          @callbacks ||= {}
        end

        def variables
          @variables ||= Set.new
        end

        def additional_variables
          variables - %i(encoder options state states match kind)
        end

        def name_for_callback block
          base_name = "__callback_line_#{block.source_location.last}"
          callback_name = base_name
          counter = 'a'

          while callbacks.key?(callback_name)
            callback_name = "#{base_name}_#{counter}"
            counter.succ!
          end
          
          callback_name
        end

        def scan_tokens_code
          <<-"RUBY"
    def scan_tokens encoder, options
      state = options[:state] || @state

#{ restore_local_variables_code.chomp.gsub(/^/, '  ' * 3) }

      states = [state]

      until eos?
        case state
#{ states_code.chomp.gsub(/^/, '  ' * 4) }
        else
          raise_inspect 'Unknown state: %p' % [state], encoder
        end
      end

      if options[:keep_state]
        @state = state
      end

#{ close_groups_code.chomp.gsub(/^/, '  ' * 3) }

      encoder
    end
          RUBY
        end

        def states_code
          states.values.map(&:rules_code).join
        end

        def restore_local_variables_code
          additional_variables.sort.map { |name| "#{name} = @#{name}" }.join("\n")
        end

        def close_groups_code
          "close_groups(encoder, states)"
        end
      end

      def scan_tokens tokens, options
        self.class.define_scan_tokens!

        scan_tokens tokens, options
      end

      protected

      def setup
        @state = :initial
        reset_expectations
      end

      def close_groups encoder, states
        # TODO
      end

      def expect kind
        @expected = kind
      end

      def expected? kind
        @expected == kind
      end

      def reset_expectations
        @expected = nil
      end
    end
  end
end
