module CodeRay
module Encoders
  
  # = Debug Lint Encoder
  #
  # Debug encoder with additional checks for:
  # 
  # - empty tokens
  # - incorrect nesting
  # 
  # It will raise an InvalidTokenStream exception when any of the above occurs.
  # 
  # See also: Encoders::Debug
  class DebugLint < Debug
    
    register_for :debug_lint
    
    InvalidTokenStream = Class.new StandardError
    EmptyToken = Class.new InvalidTokenStream
    IncorrectTokenGroupNesting = Class.new InvalidTokenStream
    
    def text_token text, kind
      raise EmptyToken, 'empty token' if text.empty?
      super
    end
    
    def begin_group kind
      @opened << kind
      super
    end
    
    def end_group kind
      raise IncorrectTokenGroupNesting, 'We are inside %s, not %p (end_group)' % [@opened.reverse.map(&:inspect).join(' < '), kind] if @opened.last != kind
      @opened.pop
      super
    end
    
    def begin_line kind
      @opened << kind
      super
    end
    
    def end_line kind
      raise IncorrectTokenGroupNesting, 'We are inside %s, not %p (end_line)' % [@opened.reverse.map(&:inspect).join(' < '), kind] if @opened.last != kind
      @opened.pop
      super
    end
    
    protected
    
    def setup options
      super
      @opened = []
    end
    
    def finish options
      raise 'Some tokens still open at end of token stream: %p' % [@opened] unless @opened.empty?
      super
    end
    
  end
  
end
end
