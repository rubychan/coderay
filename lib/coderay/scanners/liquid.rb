module CodeRay
module Scanners

  class Liquid < Scanner
    
    register_for :liquid
   
    DIRECTIVE_KEYWORDS = /endlist|list|endfor|for|endwrap|wrap|endif|if|endunless|unless|elsif|assignlist|assign|cycle|capture|end|capture|fill|endiflist|iflist|else/

    MATH = /==|=|!=|>|<=|<|>|\+/

    DIRECTIVE_PREPOSITIONS= /contains|in|#{MATH}/

    FILTER_KEYWORDS = /#{FILTER_WITH_VALUE_KEYWORDS}|textilize|capitalize|downcase|upcase|first|last|sort|map|size|escape_once|escape|strip_html|strip_newlines|newline_to_br/

    FILTER_WITH_VALUE_KEYWORDS = /date|replace_first|replace|remove_first|remove_first|remove|minus|times|divided_by|modulo|mod|split|join|truncatewords|truncate|prepend|append/

    SELECTOR_KEYWORDS = /in|with|snippet|script|content_item|folder|widget|wrapper|category|asset_folder|asset/

    DIRECTIVE_KEYS = /#{SELECTOR_KEYWORDS}|tabs|items_per_tab/

    LIQUID_DIRECTIVE_BLOCK = /
      {{1,2}%
      (.*?)
      %}{1,2}
    /x

    def setup
      @html_scanner = CodeRay.scanner(:html, tokens: @tokens, keep_tokens: true, keep_state: true)
    end

    def scan_spaces(encoder)
      if match = scan(/\s+/)
        encoder.text_token match, :space
      end
    end

    def scan_key_value_pair(encoder, options, match)
      scan_spaces(encoder)
      if match =~ /#{SELECTOR_KEYWORDS}/
        encoder.text_token match, :directive
      else
        encoder.text_token match, :key
      end
      if delimiter = scan(/:/)
        encoder.text_token delimiter, :delimiter
        scan_spaces(encoder)
      end
      if value = scan(/\w+/)
        encoder.text_token value, :value 
      elsif value = scan(/('\S+')|("\w+")/)
        encoder.text_token value, :string
      end
    end

    def scan_selector(encoder, options, match)
      scan_spaces(encoder)
      Rails.logger.debug 'DEBUG: Looking for a selector'
      if match = scan(/#{DIRECTIVE_KEYS}/) 
        if peek(1) == ':'
          Rails.logger.debug "DEBUG: Peek: #{peek(5)}"
          Rails.logger.debug 'DEBUG: Selector keyword found'
          scan_key_value_pair(encoder, options, match)
        else 
          encoder.text_token match, :variable
        end
        scan_selector(encoder, options, match)
      else
        false
      end
    end

    def scan_directive(encoder, options, match)
      Rails.logger.debug 'DEBUG: Scanning directive'
      encoder.text_token match, :tag
      state = :liquid
      scan_spaces(encoder)
      if match = scan(/#{DIRECTIVE_KEYWORDS}/)
        encoder.text_token match, :directive
        scan_spaces(encoder)
        if match =~ /if|assign|assignlist/
          scan_selector(encoder, options, match)
          if match = scan(/\w+\.?\w*/)
            encoder.text_token match, :variable
          end
          scan_spaces(encoder)
          if match = scan(/#{DIRECTIVE_PREPOSITIONS}/)
            encoder.text_token match, :operator
            scan_spaces(encoder)
            scan_selector(encoder, options, match)
          end
          if match = scan(/(\w+)|('\S+')|(".+")/)
            encoder.text_token match, :variable
            scan_spaces(encoder)
          end
        end
      end
      scan_selector(encoder, options, match)
      scan_spaces(encoder)
      if match = scan(/%}{1,2}/)
        encoder.text_token match, :tag
        state = :initial
      end
    end

    def scan_output_filters(encoder, options, match)
      encoder.text_token match, :operator
      scan_spaces(encoder)
      if match = scan(/#{FILTER_WITH_VALUE_KEYWORDS}/)
        scan_key_value_pair(encoder, options, match)
      elsif directive = scan(/#{FILTER_KEYWORDS}/)
        encoder.text_token directive, :directive
      end
      if next_filter = scan(/\s\|\s/)
        scan_output_filters(encoder, options, next_filter)
      end
    end

    def scan_output(encoder, options, match)
      Rails.logger.debug 'DEBUG: Scanning output'
      encoder.text_token match, :tag
      state = :liquid
      scan_spaces(encoder)
      if match = scan(/(\w+\.?\w*)|('\S+')|("\w+")/)
        encoder.text_token match, :variable
      end
      if match = scan(/(\s\|\s)/)
        scan_output_filters(encoder, options, match)   
      end
      scan_spaces(encoder)
      if match = scan(/}{2,3}/)
        encoder.text_token match, :tag
      end
      state = :initial
    end

    def scan_tokens(encoder, options)
      Rails.logger.debug "DEBUG: Scan started: #{self.string}"
      state = :initial

      until eos?
        if (match = scan_until(/(?=({{2,3}|{{1,2}%))/) || scan_rest) and not match.empty? and state != :liquid
          Rails.logger.debug "DEBUG: HTML scanning: #{match}"
          if match =~ /^"|^'/
            @html_scanner.tokenize(match, { tokens: encoder, state: :attribute_value_string })
          else
            @html_scanner.tokenize(match, tokens: encoder)
          end
          state = :initial
        scan_spaces(encoder)
        elsif match = scan(/{{1,2}%/)
          scan_directive(encoder, options, match) 
        elsif match = scan(/{{2,3}/)
          scan_output(encoder, options, match)
        else
          raise "Else-case reached. State: #{state.to_s}."
        end
      end
      encoder
    end
  end
end
end
