module CodeRay
  
  class TokensProxy < Struct.new :code, :lang, :options, :block
    
    def method_missing method, *args, &blk
      tokens.send(method, *args, &blk)
    end
    
    def tokens
      @tokens ||= scanner.tokenize(code)
    end
    
    def each *args, &blk
      tokens.each(*args, &blk)
    end
    
    def count
      tokens.count
    end
    
    def scanner
      @scanner ||= CodeRay.scanner(lang, options, &block)
    end
    
  end
  
end
