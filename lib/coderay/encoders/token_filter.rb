module CodeRay
module Encoders

  class TokenFilter < Encoder

    include Streamable
    register_for :token_filter

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
      if @exclude.include?(kind) ||
        @include != :all && !@include.include?(kind)
        ''
      else
        text
      end
    end

  end

end
end
