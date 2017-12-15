module CodeRay
module Encoders
  
  # = Debug Encoder
  #
  # Fast encoder producing simple debug output.
  #
  # It is readable and diff-able and is used for testing.
  #
  # You cannot fully restore the tokens information from the
  # output, because consecutive :space tokens are merged.
  # 
  # See also: Scanners::Debug
  class Debug < Encoder
    
    register_for :debug
    
    attr_reader :size
    
    FILE_EXTENSION = 'raydebug'
    
    def text_token text, kind
      @size += 1
      if kind == :space
        @out << text
      else
        text = text.gsub('\\', '\\\\\\\\') if text.index('\\')
        text = text.gsub(')',  '\\\\)')    if text.index(')')
        @out << "#{kind}(#{text})"
      end
    end
    
    def begin_group kind
      @out << "#{kind}<"
    end
    
    def end_group kind
      @out << '>'
    end
    
    def begin_line kind
      @out << "#{kind}["
    end
    
    def end_line kind
      @out << ']'
    end
    
    protected
    
    def setup options
      super
      @size = 0
    end
    
  end
  
end
end
