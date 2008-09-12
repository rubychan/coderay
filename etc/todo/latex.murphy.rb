module CodeRay
module Encoders

  class Latex < Encoder

    include Streamable
    register_for :latex

    FILE_EXTENSION = 'tex'
    
    ALLTT_ESCAPE = {  #:nodoc:
      '{' => '\lb',
      '}' => '\rb',
      '\\' => '\bs',
    }

    HTML_ESCAPE_PATTERN = /[\\{}]/

  protected
    
    def text_token text, kind
      if text =~ /#{HTML_ESCAPE_PATTERN}/o
        text = text.gsub(/#{HTML_ESCAPE_PATTERN}/o) { |m| @HTML_ESCAPE[m] }
      end
      k = Tokens::ClassOfKind[kind]
      if k == :NO_HIGHLIGHT
        text
      else
        "\\CR#{k}{#{text}}"
      end
    end

    def open_token kind
      "\\CR#{Tokens::ClassOfKind[kind]}{"
    end

    def close_token kind
      "}"
    end

  end

end
end
