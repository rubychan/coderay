module CodeRay
module Scanners
  
  class RuleBasedScanner3 < Scanner
    class << self
      attr_accessor :states
      
      def state *names, &block
        @@code ||= ""
        
        @@code << "when #{names.map(&:inspect).join(', ')}\n"
        
        @@first = true
        instance_eval(&block)
        @@code << "  else\n"
        # @@code << "    raise 'no match for #{names.map(&:inspect).join(', ')}'\n"
        @@code << "    encoder.text_token getch, :error\n"
        @@code << "  end\n"
        @@code << "  \n"
      end
      
      def token pattern, *actions
        @@code << "  #{'els' unless @@first}if match = scan(#{pattern.inspect})\n"
        
        for action in actions
          case action
          when Symbol
            @@code << "    p 'text_token %p %p' % [match, #{action.inspect}]\n" if $DEBUG
            @@code << "    encoder.text_token match, #{action.inspect}\n"
          when Array
            case action.first
            when :begin_group
              @@code << "    p 'begin_group %p' % [#{action.last.inspect}]\n" if $DEBUG
              @@code << "    state = #{action.last.inspect}\n"
              @@code << "    states << #{action.last.inspect}\n"
              @@code << "    encoder.begin_group #{action.last.inspect}\n"
            when :end_group
              @@code << "    p 'end_group %p' % [states.last]\n" if $DEBUG
              @@code << "    encoder.end_group states.pop\n"
              @@code << "    state = states.last\n"
            end
          end
        end
        
        @@first = false
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
  class JSON3 < RuleBasedScanner3
    
    register_for :json3
    file_extension 'json3'
    
    KINDS_NOT_LOC = [
      :float, :char, :content, :delimiter,
      :error, :integer, :operator, :value,
    ]  # :nodoc:
    
    ESCAPE = / [bfnrt\\"\/] /x  # :nodoc:
    UNICODE_ESCAPE = / u[a-fA-F0-9]{4} /x  # :nodoc:
    KEY = / (?> (?: [^\\"]+ | \\. )* ) " \s* : /mx
    
    state :initial do
      token %r/ \s+ /x, :space
      
      token %r/ [:,\[{\]}] /x, :operator
      
      token %r/ " (?=#{KEY}) /x, push_group(:key),    :delimiter
      token %r/ " /x,            push_group(:string), :delimiter
      
      token %r/ true | false | null /x, :value
      token %r/ -? (?: 0 | [1-9]\d* ) (?: \.\d+ (?: e[-+]? \d+ )? | e[-+]? \d+ ) /ix, :float
      token %r/ -? (?: 0 | [1-9]\d* ) (?: e[+-] \d+ )? /ix, :integer
    end
    
    state :key, :string do
      token %r/ [^\\"]+ /x, :content
      
      token %r/ " /x, :delimiter, pop_group
      
      token %r/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /x, :char
      token %r/ \\. /mx, :content
      token %r/ \\ /x, pop_group, :error
    end
    
  protected
    
    def setup
      @state = :initial
    end
    
    # See http://json.org/ for a definition of the JSON lexic/grammar.
    scan_tokens_code = <<-"RUBY"
    def scan_tokens encoder, options
      state = options[:state] || @state
      
      if [:string, :key].include? state
        encoder.begin_group state
      end
      
      states = [state]
      
      until eos?
        
        case state
        
#{ @@code.chomp.gsub(/^/, '        ') }
        else
          raise_inspect 'Unknown state: %p' % [state], encoder
          
        end
        
      end
      
      if options[:keep_state]
        @state = state
      end
      
      if [:string, :key].include? state
        encoder.end_group state
      end
      
      encoder
    end
    RUBY
    
    # puts scan_tokens_code
    class_eval scan_tokens_code
    
  end
  
end
end
