module CodeRay
module Scanners
  
  # Scanner for plain text.
  # 
  # Yields just one token of the kind :plain.
  # 
  # Alias: +plain+
  class Plaintext < Scanner

    register_for :plaintext, :plain
    title 'Plain text'
    
    include Streamable
    
    KINDS_NOT_LOC = [:plain]  # :nodoc:
    
  protected
    
    def scan_tokens tokens, options
      tokens << [string, :plain]
    end

  end

end
end
