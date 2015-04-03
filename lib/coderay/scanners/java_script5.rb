# TODO: string_delimiter should be part of the state: push(:regexp, '/'), check_if -> (state, delimiter) { … }
module CodeRay
module Scanners
  
  class RuleBasedScanner6 < Scanner
    
    Groups = Struct.new :token_kinds
    Kind = Struct.new :token_kind
    Push = Struct.new :state
    Pop = Class.new
    Check = Struct.new :condition
    CheckIf = Class.new Check
    CheckUnless = Class.new Check
    ValueSetter = Struct.new :targets, :value
    
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
              @code << "    encoder.text_token match, #{make_callback(action.token_kind)}\n"
            else
              raise "I don't know how to evaluate this kind: %p" % [action.token_kind]
            end
          when Groups
            @code << "    p 'text_tokens %p in groups %p' % [match, #{action.token_kinds.inspect}]\n" if $DEBUG
            action.token_kinds.each_with_index do |kind, i|
              @code << "    encoder.text_token self[#{i + 1}], #{kind.inspect} if self[#{i + 1}]\n"
            end
          
          when Push
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
            @code << "    encoder.begin_group state\n"
          when Pop
            @code << "    p 'pop %p' % [states.last]\n" if $DEBUG
            @code << "    encoder.end_group states.pop\n"
            @code << "    state = states.last\n"
          
          when ValueSetter
            case action.value
            when Proc
              @code << "    #{action.targets.join(' = ')} = #{make_callback(action.value)}\n"
            else
              @code << "    #{action.targets.join(' = ')} = #{action.value.inspect}\n"
            end
          
          when Proc
            @code << "    #{make_callback(action)}\n"
            
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
  
  # Scanner for JavaScript.
  # 
  # Aliases: +ecmascript+, +ecma_script+, +javascript+
  class JavaScript5 < RuleBasedScanner6
    
    register_for :java_script5
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
      on %r/ \s+ | \\\n /x, :space, set(:value_expected) { |match, value_expected| value_expected || match.index(?\n) }
      on %r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .*() ) !mx, :comment, flag_off(:value_expected)
        # state = :open_multi_line_comment if self[1]
      
      on? %r/\.?\d/ do
        on %r/0[xX][0-9A-Fa-f]+/, :hex, flag_off(:key_expected, :value_expected)
        on %r/(?>0[0-7]+)(?![89.eEfF])/, :octal, flag_off(:key_expected, :value_expected)
        on %r/\d+[fF]|\d*\.\d+(?:[eE][+-]?\d+)?[fF]?|\d+[eE][+-]?\d+[fF]?/, :float, flag_off(:key_expected, :value_expected)
        on %r/\d+/, :integer, flag_off(:key_expected, :value_expected)
      end
      
      on check_if(:value_expected), %r/<([[:alpha:]]\w*) (?: [^\/>]*\/> | .*?<\/\1>)/xim, -> (match, encoder) do
        # TODO: scan over nested tags
        xml_scanner.tokenize match, :tokens => encoder
      end, flag_off(:value_expected)
      
      on %r/ [-+*=<>?:;,!&^|(\[{~%]++ (?<![{,]) | \.+(?!\d) /x, :operator, flag_on(:value_expected), flag_off(:key_expected, :function_expected)
      on %r/ [-+*=<>?:;,!&^|(\[{~%]*+ (?<=[{,]) /x, :operator, flag_on(:value_expected, :key_expected), flag_off(:function_expected)
      on %r/ [)\]}]+ /x, :operator, flag_off(:function_expected, :key_expected, :value_expected)
      
      on %r/ function (?![A-Za-z_0-9$]) /x, :keyword, flag_on(:function_expected), flag_off(:key_expected, :value_expected)
      on %r/ [$a-zA-Z_][A-Za-z_0-9$]* /x, kind { |match, function_expected, key_expected|
        kind = IDENT_KIND[match]
        # TODO: labels
        if kind == :ident
          if match.index(?$)  # $ allowed inside an identifier
            kind = :predefined
          elsif function_expected
            kind = :function
          elsif check(/\s*[=:]\s*function\b/)
            kind = :function
          elsif key_expected && check(/\s*:/)
            kind = :key
          end
        end
        
        kind
      }, flag_off(:function_expected, :key_expected), set(:value_expected) { |match| KEYWORDS_EXPECTING_VALUE[match] }
      
      on %r/["']/, push { |match, key_expected| key_expected && check(KEY_CHECK_PATTERN[match]) ? :key : :string }, :delimiter, set(:string_delimiter) { |match| match }
      on check_if(:value_expected), %r/\//, push(:regexp), :delimiter
      
      on %r/\//, :operator, flag_on(:value_expected), flag_off(:key_expected)
    end
    
    state :string, :key do
      on -> (string_delimiter) { STRING_CONTENT_PATTERN[string_delimiter] }, :content
      on %r/["']/, :delimiter, unset(:string_delimiter), flag_off(:key_expected, :value_expected), pop
      on %r/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /x, kind { |match, string_delimiter|
        string_delimiter == "'" && !(match == "\\\\" || match == "\\'") ? :content : :char
      }
      on %r/ \\. /mx, :content
      on %r/ \\ /x, unset(:string_delimiter), flag_off(:key_expected, :value_expected), pop, :error
    end
    
    state :regexp do
      on STRING_CONTENT_PATTERN['/'], :content
      on %r/(\/)([gim]+)?/, groups(:delimiter, :modifier), flag_off(:key_expected, :value_expected), pop
      on %r/ \\ (?: #{ESCAPE} | #{REGEXP_ESCAPE} | #{UNICODE_ESCAPE} ) /x, :char
      on %r/\\./m, :content
      on %r/ \\ /x, pop, :error, flag_off(:key_expected, :value_expected)
    end
    
    # state :open_multi_line_comment do
    #   on %r! .*? \*/ !mx, :initial  # don't consume!
    #   on %r/ .+ /mx, :comment, -> { value_expected = true }
    #
    #   # if match = scan(%r! .*? \*/ !mx)
    #   #   state = :initial
    #   # else
    #   #   match = scan(%r! .+ !mx)
    #   # end
    #   # value_expected = true
    #   # encoder.text_token match, :comment if match
    # end
    
  protected
    
    def setup
      @state = :initial
    end
    
    scan_tokens_code = <<-"RUBY"
    def scan_tokens encoder, options#{ def_line = __LINE__; nil }
      state, string_delimiter = options[:state] || @state
      if string_delimiter
        encoder.begin_group state
      end
      
      value_expected = true
      key_expected = false
      function_expected = false
      
      states = [state]
      
      until eos?
        
        case state
        
#{ @code.chomp.gsub(/^/, '        ') }
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
    
    if ENV['PUTS']
      puts scan_tokens_code
      puts "callbacks: #{@callbacks.size}"
    end
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
