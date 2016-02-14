# encoding: utf-8

module CodeRay
module Scanners

  # Scanner for the Lua[http://lua.org] programming lanuage.
  #
  # The language’s complete syntax is defined in
  # {the Lua manual}[http://www.lua.org/manual/5.2/manual.html],
  # which is what this scanner tries to conform to.
  class Lua2 < RuleBasedScanner
    
    register_for :lua2
    file_extension 'lua'
    title 'Lua'
    
    # Keywords used in Lua.
    KEYWORDS = %w[and break do else elseif end
      for function goto if in
      local not or repeat return
      then until while
    ]
    
    # Constants set by the Lua core.
    PREDEFINED_CONSTANTS = %w[false true nil]
    
    # The expressions contained in this array are parts of Lua’s `basic'
    # library. Although it’s not entirely necessary to load that library,
    # it is highly recommended and one would have to provide own implementations
    # of some of these expressions if one does not do so. They however aren’t
    # keywords, neither are they constants, but nearly predefined, so they
    # get tagged as `predefined' rather than anything else.
    #
    # This list excludes values of form `_UPPERCASE' because the Lua manual
    # requires such identifiers to be reserved by Lua anyway and they are
    # highlighted directly accordingly, without the need for specific
    # identifiers to be listed here.
    PREDEFINED_EXPRESSIONS = %w[
      assert collectgarbage dofile error getmetatable
      ipairs load loadfile next pairs pcall print
      rawequal rawget rawlen rawset select setmetatable
      tonumber tostring type xpcall
    ]
    
    # Automatic token kind selection for normal words.
    IDENT_KIND = CodeRay::WordList.new(:ident).
      add(KEYWORDS, :keyword).
      add(PREDEFINED_CONSTANTS, :predefined_constant).
      add(PREDEFINED_EXPRESSIONS, :predefined)
    
    protected
    
    # Scanner initialization.
    def setup
      super
      @brace_depth = 0
      @num_equals = nil
    end
    
    state :initial, :map do
      on %r/\-\-\[\=*\[/, push(:long_comment, :comment), :delimiter,  #--[[ long (possibly multiline) comment ]]
        set(:num_equals, -> (match) { match.count('=') }) # Number must match for comment end
      on %r/--.*$/, :comment  # --Lua comment
      on %r/\[=*\[/, push(:long_string, :string), :delimiter,  # [[ long (possibly multiline) string ]]
        set(:num_equals, -> (match) { match.count('=') }) # Number must match for string end
      on %r/::\s*[a-zA-Z_][a-zA-Z0-9_]+\s*::/, :label  # ::goto_label::
      on %r/_[A-Z]+/, :predefined  # _UPPERCASE are names reserved for Lua
      on check_if { |brace_depth| brace_depth > 0 }, %r/([a-zA-Z_][a-zA-Z0-9_]*) (\s+)?(=)/x, groups(:key, :space, :operator)
      on %r/[a-zA-Z_][a-zA-Z0-9_]*/, kind { |match| IDENT_KIND[match] }, push_state { |match, kind|  # Normal letters (or letters followed by digits)
        # Extra highlighting for entities following certain keywords
        if kind == :keyword && match == 'function'
          :function_expected
        elsif kind == :keyword && match == 'goto'
          :goto_label_expected
        elsif kind == :keyword && match == 'local'
          :local_var_expected
        end
      }
      
      on %r/\{/, push(:map), kind { |brace_depth| brace_depth > 0 ? :inline_delimiter : :delimiter }, increment(:brace_depth)  # Opening table brace {
      on check_if { |brace_depth| brace_depth == 1 }, %r/\}/, :delimiter, pop, decrement(:brace_depth) # Closing table brace }
      on check_if { |brace_depth| brace_depth == 0 }, %r/\}/, :error # Mismatched brace
      on %r/\}/, :inline_delimiter, pop, decrement(:brace_depth)
      
      on %r/"/, push(:double_quoted_string, :string), :delimiter  # String delimiters " and '
      on %r/'/, push(:single_quoted_string, :string), :delimiter
          # ↓Prefix                hex number ←|→ decimal number
      on %r/-? (?:0x\h* \. \h+ (?:p[+\-]?\d+)? | \d*\.\d+ (?:e[+\-]?\d+)?)/ix, :float  # hexadecimal constants have no E power, decimal ones no P power
          # ↓Prefix         hex number ←|→ decimal number
      on %r/-? (?:0x\h+ (?:p[+\-]?\d+)? | \d+ (?:e[+\-]?\d+)?)/ix, :integer  # hexadecimal constants have no E power, decimal ones no P power
      on %r/[\+\-\*\/%^\#=~<>\(\)\[\]:;,] | \.(?!\d)/x, :operator  # Operators
      on %r/\s+/, :space  # Space
    end
    
    state :function_expected do
      on %r/\(.*?\)/m, :operator, pop_state  # x = function() # "Anonymous" function without explicit name
      on %r/[a-zA-Z_] (?:[a-zA-Z0-9_\.] (?!\.\d))* [\.\:]/x, :ident  # function tbl.subtbl.foo() | function tbl:foo() # Colon only allowed as last separator
      on %r/[a-zA-Z_][a-zA-Z0-9_]*/, :function, pop_state  # function foo()
      on %r/\s+/, :space # Between the `function' keyword and the ident may be any amount of whitespace
    end
    
    state :goto_label_expected do
      on %r/[a-zA-Z_][a-zA-Z0-9_]*/, :label, pop_state
      on %r/\s+/, :space  # Between the `goto' keyword and the label may be any amount of whitespace
    end
    
    state :local_var_expected do
      on %r/function/, :keyword, pop_state, push_state(:function_expected)  # local function ...
      on %r/[a-zA-Z_][a-zA-Z0-9_]*/, :local_variable
      on %r/,/, :operator
      on %r/\=/, :operator, pop_state
      on %r/\n/, :space, pop_state
      on %r/\s+/, :space
    end
    
    state :long_comment do
      on pattern { |num_equals| %r/(.*?)(\]={#{num_equals}}\])/m }, groups(:content, :delimiter), pop(:comment)
      on %r/.*/m, :error, pop(:comment)
    end
    
    state :long_string do
      on pattern { |num_equals| %r/(.*?)(\]={#{num_equals}}\])/m }, groups(:content, :delimiter), pop(:string)  # Long strings do not interpret any escape sequences
      on %r/.*/m, :error, pop(:string)
    end
    
    state :single_quoted_string do
      on %r/[^\\'\n]+/, :content  # Everything except \ and the start delimiter character is string content (newlines are only allowed if preceeded by \ or \z)
      on %r/\\(?:["'abfnrtv\\]|z\s*|x\h\h|\d{1,3}|\n)/m, :char
      on %r/'/, :delimiter, pop(:string)
      on %r/\n/, :error, pop(:string)  # Lua forbids unescaped newlines in normal non-long strings
      # encoder.text_token("\\n\n", :error) # Visually appealing error indicator--otherwise users may wonder whether the highlighter cannot highlight multine strings
    end
    
    state :double_quoted_string do
      on %r/[^\\"\n]+/, :content  # Everything except \ and the start delimiter character is string content (newlines are only allowed if preceeded by \ or \z)
      on %r/\\(?:["'abfnrtv\\]|z\s*|x\h\h|\d{1,3}|\n)/m, :char
      on %r/"/, :delimiter, pop(:string)
      on %r/\n/, :error, pop(:string)  # Lua forbids unescaped newlines in normal non-long strings
      # encoder.text_token("\\n\n", :error) # Visually appealing error indicator--otherwise users may wonder whether the highlighter cannot highlight multine strings
    end
    
    scan_tokens_code = <<-"RUBY"
    def scan_tokens encoder, options#{ def_line = __LINE__; nil }
      state = options[:state] || @state
      brace_depth = @brace_depth
      num_equals = nil
      
      states = [state]
      
      until eos?
        case state
#{ @code.chomp.gsub(/^/, '        ') }
        else
          raise_inspect 'Unknown state: %p' % [state], encoder
        end
      end
      
      if options[:keep_state]
        @state = state
      end
      
      encoder.end_group :string if [:string, :single_quoted_string, :double_quoted_string].include? state
      brace_depth.times { encoder.end_group :map }
      
      encoder
    end
    RUBY
    
    if ENV['PUTS']
      puts CodeRay.scan(scan_tokens_code, :ruby).terminal
      puts "callbacks: #{callbacks.size}"
    end
    class_eval scan_tokens_code, __FILE__, def_line
  end
  
end
end
