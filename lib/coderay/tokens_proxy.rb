module CodeRay
  
  class TokensProxy < Struct.new :input, :lang, :options, :block
    
    def method_missing method, *args, &blk
      encode method, *args
    rescue PluginHost::PluginNotFound
      tokens.send(method, *args, &blk)
    end
    
    def tokens
      @tokens ||= scanner.tokenize(input)
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
    
    def encode encoder, options = {}
      if encoder.respond_to? :to_sym
        CodeRay.encode(input, lang, encoder, options)
      else
        encoder.encode_tokens tokens, options
      end
    end
    
  end
  
end
