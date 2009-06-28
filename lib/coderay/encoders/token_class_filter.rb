module CodeRay
module Encoders
  
  load :filter
  
  class TokenClassFilter < Filter

    include Streamable
    register_for :token_class_filter

    DEFAULT_OPTIONS = {
      :exclude => [],
      :include => :all
    }

  protected
    def setup options
      super
      @exclude = options[:exclude]
      @include = options[:include]
    end
    
    def text_token text, kind
      [text, kind] if !@exclude.include?(kind) &&
        (@include == :all || @include.include?(kind))
    end

  end

end
end
