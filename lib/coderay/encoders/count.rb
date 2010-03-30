module CodeRay
module Encoders
  
  # Returns the number of tokens.
  # 
  # Text and block tokens (:open etc.) are counted.
  class Count < Encoder

    include Streamable
    register_for :count

  protected

    def setup options
      @out = 0
    end

    def token text, kind
      @out += 1
    end
    
  end

end
end
