module CodeRay
module Scanners
  
  class JSON2RuleBasedScanner < Scanner
    class << self
      attr_accessor :states
      
      def state *names, &block
        @@states ||= {}
        
        @@rules = []
        
        instance_eval(&block)
        
        for name in names
          @@states[name] = @@rules
        end
        
        @@rules = nil
      end
      
      def token pattern, *actions
        @@rules << [pattern, *actions]
      end
      
      def push_group name
        [:begin_group, name]
      end
      
      def pop_group
        [:end_group]
      end
    end
  end
  
  # Scanner for JSON (JavaScript Object Notation).
  class JSON2 < JSON2RuleBasedScanner
    
    register_for :json2
    file_extension 'json'
    
    KINDS_NOT_LOC = [
      :float, :char, :content, :delimiter,
      :error, :integer, :operator, :value,
    ]  # :nodoc:
    
    ESCAPE = / [bfnrt\\"\/] /x  # :nodoc:
    UNICODE_ESCAPE = / u[a-fA-F0-9]{4} /x  # :nodoc:
    KEY = / (?> (?: [^\\"]+ | \\. )* ) " \s* : /mx
    
    state :initial do
      token %r/ \s+ /x, :space
      
      token %r/ " (?=#{KEY}) /x, push_group(:key),    :delimiter
      token %r/ " /x,            push_group(:string), :delimiter
      
      token %r/ [:,\[{\]}] /x, :operator
      
      token %r/ true | false | null /x, :value
      token %r/ -? (?: 0 | [1-9]\d* ) (?: \.\d+ (?: [eE][-+]? \d+ )? | [eE][-+]? \d+ ) /x, :float
      token %r/ -? (?: 0 | [1-9]\d* ) /x, :integer
    end
    
    state :string, :key do
      token %r/ [^\\"]+ /x, :content
      
      token %r/ " /x, :delimiter, pop_group
      
      token %r/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /x, :char
      token %r/ \\. /mx, :content
      token %r/ \\ /x, pop_group, :error
      
      # token %r/$/, end_group
    end
    
  protected
    
    def setup
      @state = :initial
    end
    
    # See http://json.org/ for a definition of the JSON lexic/grammar.
    def scan_tokens encoder, options
      state = options[:state] || @state
      
      if [:string, :key].include? state
        encoder.begin_group state
      end
      
      states = [state]
      
      until eos?
        for pattern, *actions in @@states[state]
          if match = scan(pattern)
            for action in actions
              case action
              when Symbol
                encoder.text_token match, action
              when Array
                case action.first
                when :begin_group
                  encoder.begin_group action.last
                  state = action.last
                  states << state
                when :end_group
                  encoder.end_group states.pop
                  state = states.last
                end
              end
            end
            
            break
          end
        end && encoder.text_token(getch, :error)
      end
      
      if options[:keep_state]
        @state = state
      end
      
      if [:string, :key].include? state
        encoder.end_group state
      end
      
      encoder
    end
    
  end
  
end
end
