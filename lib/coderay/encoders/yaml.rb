module CodeRay
module Encoders
  
  # = YAML Encoder
  #
  # Slow.
  class YAML < Encoder
    
    register_for :yaml
    
    FILE_EXTENSION = 'yaml'
    
  protected
    def setup options
      require 'yaml'
      @out = []
    end
    
    def finish options
      @out.to_a.to_yaml
    end
    
  public
    def text_token text, kind
      @out << [text, kind]
    end
    
    def begin_group kind
      @out << [:begin_group, kind]
    end
    
    def end_group kind
      @out << [:end_group, kind]
    end
    
    def begin_line kind
      @out << [:begin_line, kind]
    end
    
    def end_line kind
      @out << [:end_line, kind]
    end
    
  end
  
end
end
