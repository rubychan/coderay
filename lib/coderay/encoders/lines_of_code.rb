module CodeRay
module Encoders
  
  class LinesOfCode < Encoder
    
    register_for :lines_of_code
    
    def compile tokens, options
      @loc = tokens.token_class_filter(:exclude => [:comment, :doctype]).text.scan(/^\s*\S.*$/).size
    end
    
    def finish options
      @loc
    end
    
  end
  
end
end
