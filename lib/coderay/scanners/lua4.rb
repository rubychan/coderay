# encoding: utf-8

module CodeRay
module Scanners

  # Scanner for the Lua[http://lua.org] programming lanuage.
  #
  # The language’s complete syntax is defined in
  # {the Lua manual}[http://www.lua.org/manual/5.2/manual.html],
  # which is what this scanner tries to conform to.
  class Lua4 < RuleBasedScanner
    
    register_for :lua4
    file_extension 'lua'
    title 'Lua'
    
    protected
    
    state :initial do
      on %r'#!(.*?)$', :doctype
      on %r//, push_state(:base)
    end
    
    state :base do
      on %r'--\[(=*)\[.*?\]\1\]'m, :comment
      on %r'--.*$', :comment

      on %r'(\d*\.\d+|\d+\.\d*)(e[+-]?\d+)?'i, :float
      on %r'\d+e[+-]?\d+'i, :float
      on %r'0x[0-9a-f]*'i, :hex
      on %r'\d+', :integer

      on %r'\n', :space
      on %r'[^\S\n]', :space
      # multiline strings
      on %r'\[(=*)\[.*?\]\1\]'m, :string

      on %r'(==|~=|<=|>=|\.\.\.|\.\.|[=+\-*/%^<>#!.\\:])', :operator
      on %r'[\[\]{}().,:;]', :operator
      on %r'(and|or|not)\b', :operator

      on %r'(break|do|else|elseif|end|for|if|in|repeat|return|then|until|while)\b', :keyword
      on %r'(local)\b', :keyword
      on %r'(true|false|nil)\b', :predefined_constant

      on %r'(function)\b', :keyword, push_state(:funcname)

      on %r'[A-Za-z_]\w*(\.[A-Za-z_]\w*)?', :ident

      # on %r"'", :string, combined(:stringescape, :sqs)
      on %r"'", :string, push_state(:sqs)
      # on %r'"', :string, combined(:stringescape, :dqs)
      on %r'"', :string, push_state(:dqs)
    end

    state :funcname do
      on %r'\s+', :space
      on %r'(?:([A-Za-z_]\w*)(\.))?([A-Za-z_]\w*)', groups(:class, :operator, :function), pop_state
      # inline function
      on %r'\(', :operator, pop_state
    end

    # if I understand correctly, every character is valid in a lua string,
    # so this state is only for later corrections
    # state :string do
    #   on %r'.', :string
    # end

    # state :stringescape do
    #   on %r/\\([abfnrtv\\"']|\d{1,3})/, :escape
    # end

    state :sqs do
      on %r"'", :string, pop_state
      # include(:string)
      on %r/\\([abfnrtv\\"']|\d{1,3})/, :escape
      on %r'.', :string
    end

    state :dqs do
      on %r'"', :string, pop_state
      # include(:string)
      on %r/\\([abfnrtv\\"']|\d{1,3})/, :escape
      on %r'.', :string
    end
  end
  
end
end
