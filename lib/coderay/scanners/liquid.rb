module CodeRay
module Scanners

  load :html

  # Scanner for Handlebars templates.
  class Liquid < Scanner

    register_for :liquid
    title 'Liquid Template'

    KINDS_NOT_LOC = HTML::KINDS_NOT_LOC

    LIQUID_OUTPUT_BLOCK = /
      ({{)
      (.*?)
      (}})
    /mx  # :nodoc:

    LIQUID_DIRECTIVE_BLOCK = /
      ({%)
      (.*?)
      (%})
    /mx  # :nodoc:

    START_OF_LIQUID = /{{|{%/  # :nodoc:

  protected

    def setup
      @html_scanner = CodeRay.scanner :html, :tokens => @tokens, :keep_tokens => true, :keep_state => true
      @liquid_attribute_scanner = CodeRay.scanner :html, :tokens => @tokens, :keep_tokens => true, :keep_state => false
    end

    def reset_instance
      super
      @html_scanner.reset
      @liquid_attribute_scanner.reset
    end

    def scan_tokens encoder, options
      until eos?
        if (match = scan_until(/(?=#{START_OF_LIQUID})/o) || scan_rest) and not match.empty?
          @html_scanner.tokenize match, :tokens => encoder

        elsif match = scan(/#{LIQUID_OUTPUT_BLOCK}/o) || match = scan(/#{LIQUID_DIRECTIVE_BLOCK}/o)

          start_tag = self[1]
          code = self[2]
          end_tag = self[3]

          encoder.begin_group :inline
          encoder.text_token start_tag, :inline_delimiter

          unless code.empty?
            @liquid_attribute_scanner.tokenize code, :tokens => encoder, :state => :attribute
          end

          encoder.text_token end_tag, :inline_delimiter unless end_tag.empty?
          encoder.end_group :inline

        else
          raise_inspect 'else-case reached!', encoder
        end
      end
      encoder
    end

  end

end
end

