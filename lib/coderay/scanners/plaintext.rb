module CodeRay
module Scanners

  class Plaintext < Scanner

    register_for :plaintext, :plain
    title 'Plain text'
    
    include Streamable
    
    KINDS_NOT_LOC = [:plain]
    
    def scan_tokens tokens, options
      tokens << [scan_rest, :plain]
    end

  end

end
end
