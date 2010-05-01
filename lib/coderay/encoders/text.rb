module CodeRay
module Encoders
  
  # Concats the tokens into a single string, resulting in the original
  # code string if no tokens were removed.
  # 
  # Alias: +plain+
  # 
  # == Options
  # 
  # === :separator
  # A separator string to join the tokens.
  # 
  # Default: empty String
  class Text < Encoder

    register_for :text

    FILE_EXTENSION = 'txt'

    DEFAULT_OPTIONS = {
      :separator => ''
    }

    def text_token text, kind
      @out << text + @sep
    end

  protected
    def setup options
      super
      @sep = options[:separator]
    end

    def finish options
      super.chomp @sep
    end

  end

end
end
