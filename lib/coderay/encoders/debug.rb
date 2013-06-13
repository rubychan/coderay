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
  # Use Tokens#dump for caching purposes.
  # 
  # See also: Scanners::Debug
  class Debug < Encoder
    
    register_for :debug
    
    FILE_EXTENSION = 'raydebug'
    
    def initialize options = {}
      super
      @opened = []
    end
    
    def text_token text, kind
      raise 'empty token' if $CODERAY_DEBUG && text.empty?
      
      if kind == :space
        @out << text
      else
        text = text.gsub('\\', '\\\\\\\\') if text.index('\\')
        text = text.gsub(')',  '\\\\)')    if text.index(')')
        @out << "#{kind}(#{text})"
      end
    end
    
    def begin_group kind
      @opened << kind if $CODERAY_DEBUG
      
      @out << "#{kind}<"
    end
    
    def end_group kind
      raise "We are inside #{@opened.inspect}, not #{kind}" if $CODERAY_DEBUG && @opened.pop != kind
      
      @out << '>'
    end
    
    def begin_line kind
      @opened << kind if $CODERAY_DEBUG
      
      @out << "#{kind}["
    end
    
    def end_line kind
      raise "We are inside #{@opened.inspect}, not #{kind}" if $CODERAY_DEBUG && @opened.pop != kind
      
      @out << ']'
    end
    
  end
  
end
end
