module CodeRay
module Encoders
  
  # A Filter encoder has another Tokens instance as output.
  # It can be subclass to select, remove, or modify tokens in the stream.
  # 
  # Subclasses of Filter are called "Filters" and can be chained.
  # 
  # == Options
  # 
  # === :tokens
  # 
  # The Tokens object which will receive the output.
  # 
  # Default: Tokens.new
  # 
  # See also: TokenKindFilter
  class Filter < Encoder
    
    register_for :filter
    
  protected
    def setup options
      @out = options[:tokens] || Tokens.new
    end
    
  public
    
    def text_token text, kind  # :nodoc:
      @out.text_token text, kind
    end
    
    def begin_group kind  # :nodoc:
      @out.begin_group kind
    end
    
    def begin_line kind  # :nodoc:
      @out.begin_line kind
    end
    
    def end_group kind  # :nodoc:
      @out.end_group kind
    end
    
    def end_line kind  # :nodoc:
      @out.end_line kind
    end
    
  end
  
end
end
