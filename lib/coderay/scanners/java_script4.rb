module CodeRay
module Scanners
  
  class RuleBasedScanner5 < Scanner
    
    CheckIf = Struct.new :callback
    
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
      
      def token *pattern_and_actions
        if index = pattern_and_actions.find_index { |item| !item.is_a?(CheckIf) }
          preconditions = pattern_and_actions[0..index - 1] if index > 0
          pattern       = pattern_and_actions[index]         or raise 'I need a pattern!'
          actions       = pattern_and_actions[index + 1..-1] or raise 'I need actions!'
        end
        
        precondition_expression = ''
        if preconditions
          for precondition in preconditions
            case precondition
            when CheckIf
              callback = make_callback(precondition.callback)
              case precondition.callback.arity
              when 0
                arguments = ''
              when 1
                arguments = '(state)'
              else
                raise "I got %p arguments for precondition: %p, but I only know how to evaluate 0..1" % [precondition.callback.arity, callback]
              end
              precondition_expression << "#{callback}#{arguments} && "
            else
              raise "I don't know how to evaluate this precondition: %p" % [precondition]
            end
          end
        end
        
        case pattern
        when Regexp
          pattern_expression = pattern.inspect
        when Proc
          pattern_expression = make_callback(pattern).to_s
        else
          raise "I don't know how to evaluate this pattern: %p" % [pattern]
        end
        
        @@code << "  #{'els' unless @@first}if #{precondition_expression}match = scan(#{pattern_expression})\n"
        
        for action in actions
          case action
          when Symbol
            @@code << "    p 'text_token %p %p' % [match, #{action.inspect}]\n" if $DEBUG
            @@code << "    encoder.text_token match, #{action.inspect}\n"
          when Array
            case action.first
            when :push
              case action.last
              when Symbol
                @@code << "    p 'push %p' % [#{action.last.inspect}]\n" if $DEBUG
                @@code << "    state = #{action.last.inspect}\n"
              when Proc
                callback = make_callback(action.last)
                case action.last.arity
                when 0
                  arguments = ''
                when 1
                  arguments = '(match)'
                else
                  raise "I got %p arguments for push: %p, but I only know how to evaluate 0..1" % [action.last.arity, callback]
                end
                @@code << "    p 'push %p' % [#{callback}]\n" if $DEBUG
                @@code << "    state = #{callback}#{arguments}\n"
              else
                raise "I don't know how to evaluate this push state: %p" % [action.last]
              end
              @@code << "    states << state\n"
              @@code << "    encoder.begin_group state\n"
            when :pop
              @@code << "    p 'pop %p' % [states.last]\n" if $DEBUG
              @@code << "    encoder.end_group states.pop\n"
              @@code << "    state = states.last\n"
            end
          when Proc
            callback = make_callback(action)
            case action.arity
            when 0
              arguments = ''
            when 1
              arguments = '(match)'
            when 2
              arguments = '(match, encoder)'
            else
              raise "I got %p arguments for action: %p, but I only know how to evaluate 0..2" % [action.arity, callback]
            end
            @@code << "    p 'calling %p'\n" % [callback] if $DEBUG
            @@code << "    #{callback}#{arguments}\n"
            
          else
            raise "I don't know how to evaluate this action: %p" % [action]
          end
        end
        
        @@first = false
      end
      
      def push state = nil, &block
        raise 'push requires a state or a block; got nothing' unless state || block
        [:push, state || block]
      end
      
      def pop
        [:pop]
      end
      
      def check_if &callback
        CheckIf.new callback
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
      end
    end
  end
  
  # Scanner for JavaScript.
  # 
  # Aliases: +ecmascript+, +ecma_script+, +javascript+
  class JavaScript4 < RuleBasedScanner5
    
    register_for :java_script4
    file_extension 'js'
    
    # The actual JavaScript keywords.
    KEYWORDS = %w[
      break case catch continue default delete do else
      finally for function if in instanceof new
      return switch throw try typeof var void while with
    ]  # :nodoc:
    PREDEFINED_CONSTANTS = %w[
      false null true undefined NaN Infinity
    ]  # :nodoc:
    
    MAGIC_VARIABLES = %w[ this arguments ]  # :nodoc: arguments was introduced in JavaScript 1.4
    
    KEYWORDS_EXPECTING_VALUE = WordList.new.add %w[
      case delete in instanceof new return throw typeof with
    ]  # :nodoc:
    
    # Reserved for future use.
    RESERVED_WORDS = %w[
      abstract boolean byte char class debugger double enum export extends
      final float goto implements import int interface long native package
      private protected public short static super synchronized throws transient
      volatile
    ]  # :nodoc:
    
    IDENT_KIND = WordList.new(:ident).
      add(RESERVED_WORDS, :reserved).
      add(PREDEFINED_CONSTANTS, :predefined_constant).
      add(MAGIC_VARIABLES, :local_variable).
      add(KEYWORDS, :keyword)  # :nodoc:
    
    ESCAPE = / [bfnrtv\n\\'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} /x  # :nodoc:
    UNICODE_ESCAPE =  / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x  # :nodoc:
    REGEXP_ESCAPE =  / [bBdDsSwW] /x  # :nodoc:
    STRING_CONTENT_PATTERN = {
      "'" => /[^\\']+/,
      '"' => /[^\\"]+/,
      '/' => /[^\\\/]+/,
    }  # :nodoc:
    KEY_CHECK_PATTERN = {
      "'" => / (?> [^\\']* (?: \\. [^\\']* )* ) ' \s* : /mx,
      '"' => / (?> [^\\"]* (?: \\. [^\\"]* )* ) " \s* : /mx,
    }  # :nodoc:
    
    state :initial do
      token %r/ \s+ | \\\n /x, :space, -> (match) do
        @value_expected = true if !@value_expected && match.index(?\n)
      end
      
      token %r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .*() ) !mx, :comment, -> (match) do
        @value_expected = true
        # state = :open_multi_line_comment if self[1]
      end
      
      # elsif check(/\.?\d/)
      token %r/0[xX][0-9A-Fa-f]+/, :hex, -> { @key_expected = @value_expected = false }
      token %r/(?>0[0-7]+)(?![89.eEfF])/, :octal, -> { @key_expected = @value_expected = false }
      token %r/\d+[fF]|\d*\.\d+(?:[eE][+-]?\d+)?[fF]?|\d+[eE][+-]?\d+[fF]?/, :float, -> { @key_expected = @value_expected = false }
      token %r/\d+/, :integer, -> { @key_expected = @value_expected = false }
      
      token check_if { @value_expected }, %r/<([[:alpha:]]\w*) (?: [^\/>]*\/> | .*?<\/\1>)/xim, -> (match, encoder) do
        # TODO: scan over nested tags
        xml_scanner.tokenize match, :tokens => encoder
        @value_expected = false
      end
      
      token %r/ [-+*=<>?:;,!&^|(\[{~%]+ | \.(?!\d) /x, :operator, -> (match) do
        @value_expected = true
        last_operator = match[-1]
        @key_expected = (last_operator == ?{) || (last_operator == ?,)
        @function_expected = false
      end
      
      token %r/ [)\]}]+ /x, :operator, -> { @function_expected = @key_expected = @value_expected = false }
      
      token %r/ [$a-zA-Z_][A-Za-z_0-9$]* /x, -> (match, encoder) do
        kind = IDENT_KIND[match]
        @value_expected = (kind == :keyword) && KEYWORDS_EXPECTING_VALUE[match]
        # TODO: labels
        if kind == :ident
          if match.index(?$)  # $ allowed inside an identifier
            kind = :predefined
          elsif @function_expected
            kind = :function
          elsif check(/\s*[=:]\s*function\b/)
            kind = :function
          elsif @key_expected && check(/\s*:/)
            kind = :key
          end
        end
        @function_expected = (kind == :keyword) && (match == 'function')
        @key_expected = false
        encoder.text_token match, kind
      end
      
      token %r/["']/, push { |match|
        @key_expected && check(KEY_CHECK_PATTERN[match]) ? :key : :string
      }, :delimiter, -> (match) { @string_delimiter = match }
      
      token check_if { @value_expected }, %r/\//, push(:regexp), :delimiter, -> { @string_delimiter = '/' }
      
      token %r/ \/ /x, :operator, -> { @value_expected = true; @key_expected = false }
    end
    
    state :string, :regexp, :key do
      token -> { STRING_CONTENT_PATTERN[@string_delimiter] }, :content
      
      token %r/\//, :delimiter, -> (match, encoder) do
        modifiers = scan(/[gim]+/)
        encoder.text_token modifiers, :modifier if modifiers && !modifiers.empty?
      end, -> do
        @string_delimiter = nil
        @key_expected = @value_expected = false
      end, pop
      
      token %r/["']/, :delimiter, -> do
        @string_delimiter = nil
        @key_expected = @value_expected = false
      end, pop
      
      token check_if { |state| state != :regexp }, %r/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox, -> (match, encoder) do
        if @string_delimiter == "'" && !(match == "\\\\" || match == "\\'")
          encoder.text_token match, :content
        else
          encoder.text_token match, :char
        end
      end
      
      token check_if { |state| state == :regexp }, %r/ \\ (?: #{ESCAPE} | #{REGEXP_ESCAPE} | #{UNICODE_ESCAPE} ) /mox, :char
      token %r/\\./m, :content
      token %r/ \\ /x, pop, :error, -> (match, encoder) do
        @string_delimiter = nil
        @key_expected = @value_expected = false
      end
    end
    
    state :open_multi_line_comment do
      token %r! .*? \*/ !mx, :initial  # don't consume!
      token %r/ .+ /mx, :comment, -> { @value_expected = true }
      
      # if match = scan(%r! .*? \*/ !mx)
      #   state = :initial
      # else
      #   match = scan(%r! .+ !mx)
      # end
      # value_expected = true
      # encoder.text_token match, :comment if match
    end
    
  protected
    
    def setup
      @state = :initial
    end
    
    scan_tokens_code = <<-"RUBY"
    def scan_tokens encoder, options#{ def_line = __LINE__; nil }
      state, @string_delimiter = options[:state] || @state
      if @string_delimiter
        encoder.begin_group state
      end
      
      @value_expected = true
      @key_expected = false
      @function_expected = false
      
      states = [state]
      
      until eos?
        
        case state
        
#{ @@code.chomp.gsub(/^/, '        ') }
        else
          raise_inspect 'Unknown state: %p' % [state], encoder
          
        end
        
      end
      
      if options[:keep_state]
        @state = state, string_delimiter
      end
      
      if [:string, :regexp].include? state
        encoder.end_group state
      end
      
      encoder
    end
    RUBY
    
    # puts scan_tokens_code
    class_eval scan_tokens_code, __FILE__, def_line
    
  protected
    
    def reset_instance
      super
      @xml_scanner.reset if defined? @xml_scanner
    end
    
    def xml_scanner
      @xml_scanner ||= CodeRay.scanner :xml, :tokens => @tokens, :keep_tokens => true, :keep_state => false
    end
    
  end
  
end
end
