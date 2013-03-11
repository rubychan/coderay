module CodeRay
module Scanners

  class Liquid < Scanner
    
    register_for :liquid
   
    DIRECTIVE_KEYWORDS = /(
      list|
      endlist|
      for|
      endfor|
      wrap|
      endwrap|
      if|
      endif|
      unless|
      endunless|
      elsif|
      assign|
      cycle|
      capture|
      end|
      capture|
      fill|
      iflist|
      endiflist|
      else|
    )/

    DIRECTIVE_OPERATORS = /(
      =|
      ==|
      !=|
      >|
      <|
      <=|
      >=|
      contains|
      with
    )/

    FILTER_KEYWORDS = /(
      date|
      capitalize|
      downcase|
      upcase|
      first|
      last|
      join|
      sort|
      map|
      size|
      escape|
      escape_once|
      strip_html|
      strip_newlines|
      newline_to_br|
      replace|
      replace_first|
      remove|
      remove_first|
      truncate|
      truncatewords|
      prepend|
      append|
      minus|
      plus|
      times|
      divided_by|
      split|
      modulo
   )/ 

    SELECTORS = 

    LIQUID_DIRECTIVE_BLOCK = /
      {%
      (.*?)
      %}
    /

    def setup
      @html_scanner = CodeRay.scanner(:html, tokens: @tokens, keep_tokens: true, keep_state: false)
    end

    def debug(match, debug_cycle, state)
      raise "Match: #{match}, left to scan: '#{post_match}', cycle: #{debug_cycle.to_s}, state: #{state.to_s}."
    end

    def scan_spaces(encoder)
      if match = scan(/\s+/)
        encoder.text_token match, :space
      end
    end

    def scan_directive(encoder, options, match)
      encoder.text_token match, :key
      state = :liquid
      scan_spaces(encoder)
      #This should use the DIRECTIVE_KEYWORDS regex, not sure why it doesn't work
      if match = scan(/(wrap|endwrap)/)
        encoder.text_token match, :directive
        scan_spaces(encoder)
        #Replace with DIRECTIVE_OPERATORS
        if match = scan(/with/)
          encoder.text_token match, :operator
          if delimiter = scan(/:/)
            encoder.text_token delimiter, :delimiter
            scan_spaces(encoder)
          end
          if variable = scan(/(\w+)|('\S+')|("\w+")/)
            encoder.text_token variable, :variable
          end
        end
      end
      scan_spaces(encoder)
      if match = scan(/%}/)
        encoder.text_token match, :key
        state = :initial
      end
    end

    def scan_output_filters(encoder, options, match)
      encoder.text_token match, :delimiter
      scan_spaces(encoder)
      #Replace with OUTPUT_KEYWORDS regex
      if directive = scan(/prepend|replace_first/)
        encoder.text_token directive, :directive
      end
      if delimiter = scan(/:/)
        encoder.text_token delimiter, :delimiter
      end
      scan_spaces(encoder)
      if variable = scan(/(\w+)|('\S+')|(".+")/)
        encoder.text_token variable, :variable
      end
      if next_filter = scan(/\s\|\s/)
        scan_output_filters(encoder, options, next_filter)
      end
    end

    def scan_output(encoder, options, match)
      encoder.text_token match, :key
      state = :liquid
      scan_spaces(encoder)
      if match = scan(/(\w+)|('\S+')|("\w+")/)
        encoder.text_token match, :variable
      end
      if match = scan(/(\s\|\s)/)
        scan_output_filters(encoder, options, match)   
      end
      scan_spaces(encoder)
      if match = scan(/}}/)
        encoder.text_token match, :key
      end
      state = :initial
    end

    def scan_tokens(encoder, options)
      state = :initial
      debug_cycle = 0

      until eos?
        if (match = scan_until(/(?=({{|{%))/) || scan_rest) and not match.empty? and state != :liquid
          @html_scanner.tokenize(match, tokens: encoder)
          state = :initial
        scan_spaces(encoder)
        elsif match = scan(/{%/)
          scan_directive(encoder, options, match) 
        elsif match = scan(/{{/)
          scan_output(encoder, options, match)
        else
          raise "Else-case reached. #{debug_cycle.to_s} cycles run. State: #{state.to_s}."
        end
        debug_cycle += 1
      end
      encoder
    end
  end
end
end
