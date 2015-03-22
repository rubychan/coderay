# TODO: string_delimiter should be part of the state: push(:regexp, '/'), check_if -> (state, delimiter) { … }
module CodeRay
module Scanners
  
  class RuleBasedScanner5 < Scanner
    
    CheckIf = Struct.new :condition
    
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
      
      def on? pattern
        pattern_expression = pattern.inspect
        @@code << "  #{'els' unless @@first}if check(#{pattern_expression})\n"
        
        @@first = true
        yield
        @@code << "  end\n"
        
        @@first = false
      end
      
      def on *pattern_and_actions
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
              case precondition.condition
              when Proc
                callback = make_callback(precondition.condition)
                case precondition.condition.arity
                when 0
                  arguments = ''
                when 1
                  arguments = '(state)'
                else
                  raise "I got %p arguments for precondition: %p, but I only know how to evaluate 0..1" % [precondition.condition.arity, callback]
                end
                precondition_expression << "#{callback}#{arguments} && "
              when Symbol
                precondition_expression << "#{precondition.condition} && "
              else
                raise "I don't know how to evaluate this check_if precondition: %p" % [precondition.condition]
              end
            else
              raise "I don't know how to evaluate this precondition: %p" % [precondition]
            end
          end
        end
        
        case pattern
        # when String
        #   pattern_expression = pattern
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
      
      def check_if value = nil, &callback
        CheckIf.new value || callback
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
      # on %r/ [ \t]* \n \s* /x, :space, -> { @value_expected = true }
      # on %r/ [ \t]+ | \\\n /x, :space
      on %r/ \s+ | \\\n /x, :space, -> (match) { @value_expected = true if !@value_expected && match.index(?\n) }
      
      on %r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .*() ) !mx, :comment, -> { @value_expected = true }
        # state = :open_multi_line_comment if self[1]
      
      on? %r/\.?\d/ do
        on %r/0[xX][0-9A-Fa-f]+/, :hex, -> { @key_expected = @value_expected = false }
        on %r/(?>0[0-7]+)(?![89.eEfF])/, :octal, -> { @key_expected = @value_expected = false }
        on %r/\d+[fF]|\d*\.\d+(?:[eE][+-]?\d+)?[fF]?|\d+[eE][+-]?\d+[fF]?/, :float, -> { @key_expected = @value_expected = false }
        on %r/\d+/, :integer, -> { @key_expected = @value_expected = false }
      end
      
      on check_if(:@value_expected), %r/<([[:alpha:]]\w*) (?: [^\/>]*\/> | .*?<\/\1>)/xim, -> (match, encoder) do
        # TODO: scan over nested tags
        xml_scanner.tokenize match, :tokens => encoder
        @value_expected = false
      end
      
      on %r/ [-+*=<>?:;,!&^|(\[{~%]+ | \.(?!\d) /x, :operator, -> (match) do
        @value_expected = true
        @key_expected = /[{,]$/ === match
        @function_expected = false
      end
      
      on %r/ [)\]}]+ /x, :operator, -> { @function_expected = @key_expected = @value_expected = false }
      
      on %r/ [$a-zA-Z_][A-Za-z_0-9$]* /x, -> (match, encoder) do
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
        encoder.text_token match, kind
        @function_expected = (kind == :keyword) && (match == 'function')
        @key_expected = false
      end
      
      on %r/["']/, push { |match|
        @string_delimiter = match
        @key_expected && check(KEY_CHECK_PATTERN[match]) ? :key : :string
      }, :delimiter
      
      on check_if(:@value_expected), %r/\//, push(:regexp), :delimiter, -> { @string_delimiter = '/' }
      
      on %r/ \/ /x, :operator, -> { @value_expected = true; @key_expected = false }
    end
    
    state :string, :regexp, :key do
      on -> { STRING_CONTENT_PATTERN[@string_delimiter] }, :content
      # on 'STRING_CONTENT_PATTERN[@string_delimiter]', :content
      
      # on %r/\//, :delimiter, -> (match, encoder) do
      #   modifiers = scan(/[gim]+/)
      #   encoder.text_token modifiers, :modifier if modifiers && !modifiers.empty?
      #   @string_delimiter = nil
      #   @key_expected = @value_expected = false
      # end, pop
      #
      # on %r/["']/, :delimiter, -> do
      #   @string_delimiter = nil
      #   @key_expected = @value_expected = false
      # end, pop
      
      on %r/["'\/]/, :delimiter, -> (match, encoder) do
        if match == '/'
          modifiers = scan(/[gim]+/)
          encoder.text_token modifiers, :modifier if modifiers && !modifiers.empty?
        end
        @string_delimiter = nil
        @key_expected = @value_expected = false
      end, pop
      
      on check_if { |state| state != :regexp }, %r/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox, -> (match, encoder) do
        if @string_delimiter == "'" && !(match == "\\\\" || match == "\\'")
          encoder.text_token match, :content
        else
          encoder.text_token match, :char
        end
      end
      
      on check_if { |state| state == :regexp }, %r/ \\ (?: #{ESCAPE} | #{REGEXP_ESCAPE} | #{UNICODE_ESCAPE} ) /mox, :char
      on %r/\\./m, :content
      on %r/ \\ /x, pop, :error, -> do
        @string_delimiter = nil
        @key_expected = @value_expected = false
      end
    end
    
    # state :open_multi_line_comment do
    #   on %r! .*? \*/ !mx, :initial  # don't consume!
    #   on %r/ .+ /mx, :comment, -> { @value_expected = true }
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
