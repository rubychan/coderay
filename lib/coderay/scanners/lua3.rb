# encoding: utf-8
# Pseudocode: states optionally define groups, comments removed, counter definition?

module CodeRay
module Scanners

  # Scanner for the Lua[http://lua.org] programming lanuage.
  #
  # The language’s complete syntax is defined in
  # {the Lua manual}[http://www.lua.org/manual/5.2/manual.html],
  # which is what this scanner tries to conform to.
  class Lua3 < RuleBasedScanner
    
    register_for :lua3
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
    
    counter :brace_depth
    
    state :initial, :map => :map do
      on %r/\-\-\[\=*\[/, push(:long_comment), :delimiter, set(:num_equals, -> (match) { match.count('=') })
      on %r/--.*$/, :comment
      on %r/\[=*\[/, push(:long_string), :delimiter, set(:num_equals, -> (match) { match.count('=') })
      on %r/::\s*[a-zA-Z_][a-zA-Z0-9_]+\s*::/, :label
      on %r/_[A-Z]+/, :predefined
      on check_if(:brace_depth, :>, 0), %r/([a-zA-Z_][a-zA-Z0-9_]*) (\s+)?(=)/x, groups(:key, :space, :operator)
      on %r/[a-zA-Z_][a-zA-Z0-9_]*/, kind { |match| IDENT_KIND[match] }, push_state { |match, kind|
        if kind == :keyword && match == 'function'
          :function_expected
        elsif kind == :keyword && match == 'goto'
          :goto_label_expected
        elsif kind == :keyword && match == 'local'
          :local_var_expected
        end
      }
      
      on %r/\{/, push(:map), kind { |brace_depth| brace_depth > 0 ? :inline_delimiter : :delimiter }, increment(:brace_depth)
      on check_if(:brace_depth, :==, 1), %r/\}/, :delimiter, pop, decrement(:brace_depth)
      on check_if(:brace_depth, :==, 0), %r/\}/, :error
      on %r/\}/, :inline_delimiter, pop, decrement(:brace_depth)
      
      on %r/"/, push(:double_quoted_string), :delimiter
      on %r/'/, push(:single_quoted_string), :delimiter
          
      on %r/-? (?:0x\h* \. \h+ (?:p[+\-]?\d+)? | \d*\.\d+ (?:e[+\-]?\d+)?)/ix, :float
          
      on %r/-? (?:0x\h+ (?:p[+\-]?\d+)? | \d+ (?:e[+\-]?\d+)?)/ix, :integer
      on %r/[\+\-\*\/%^\#=~<>\(\)\[\]:;,] | \.(?!\d)/x, :operator
      on %r/\s+/, :space
    end
    
    state :function_expected do
      on %r/\(.*?\)/m, :operator, pop
      on %r/[a-zA-Z_] (?:[a-zA-Z0-9_\.] (?!\.\d))* [\.\:]/x, :ident
      on %r/[a-zA-Z_][a-zA-Z0-9_]*/, :function, pop
      on %r/\s+/, :space
    end
    
    state :goto_label_expected do
      on %r/[a-zA-Z_][a-zA-Z0-9_]*/, :label, pop
      on %r/\s+/, :space
    end
    
    state :local_var_expected do
      on %r/function/, :keyword, pop, push(:function_expected)
      on %r/[a-zA-Z_][a-zA-Z0-9_]*/, :local_variable
      on %r/,/, :operator
      on %r/\=/, :operator, pop
      on %r/\n/, :space, pop
      on %r/\s+/, :space
    end
    
    state :long_comment => :comment do
      on pattern { |num_equals| %r/(.*?)(\]={#{num_equals}}\])/m }, groups(:content, :delimiter), pop(:comment)
      on %r/.*/m, :error, pop(:comment)
    end
    
    state :long_string => :string do
      on pattern { |num_equals| %r/(.*?)(\]={#{num_equals}}\])/m }, groups(:content, :delimiter), pop(:string)
      on %r/.*/m, :error, pop(:string)
    end
    
    state :single_quoted_string => :string do
      on %r/[^\\'\n]+/, :content
      on %r/\\(?:["'abfnrtv\\]|z\s*|x\h\h|\d{1,3}|\n)/m, :char
      on %r/'/, :delimiter, pop(:string)
      on %r/\n/, :error, pop(:string)
    end
    
    state :double_quoted_string => :string do
      on %r/[^\\"\n]+/, :content
      on %r/\\(?:["'abfnrtv\\]|z\s*|x\h\h|\d{1,3}|\n)/m, :char
      on %r/"/, :delimiter, pop(:string)
      on %r/\n/, :error, pop(:string)
    end
  end
  
end
end
