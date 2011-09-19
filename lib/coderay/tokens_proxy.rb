module CodeRay
  
  class TokensProxy < Struct.new :input, :lang, :options, :block
    
    def encode encoder, options = {}
      if encoder.respond_to? :to_sym
        CodeRay.encode(input, lang, encoder, options)
      else
        encoder.encode_tokens tokens, options
      end
    end
    
    def method_missing method, *args, &blk
      encode method, *args
    rescue PluginHost::PluginNotFound
      tokens.send(method, *args, &blk)
    end
    
    def tokens
      @tokens ||= scanner.tokenize(input)
    end
    
    def scanner
      @scanner ||= CodeRay.scanner(lang, options, &block)
    end
    
    def each *args, &blk
      tokens.each(*args, &blk)
      self
    end
    
    def count
      tokens.count
    end
    
  end
  
end
