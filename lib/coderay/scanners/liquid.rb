module CodeRay
module Scanners

  class Liquid < Scanner

    register_for :liquid
   
    DIRECTIVE_KEYWORDS = /endcode|code|endpaginate|endtablerow|tablerow|endifchanged|ifchanged|endcomment|comment|endcache|cache|endexpire|expire|paginate|endlist|list|endfor|for|endwrap|wrap|endif|if|endunless|unless|elsif|assignlist|assign|cycle|capture|end|capture|fill|endiflist|iflist|else/

    MATH = /==|=|!=|>|<=|<|>|\+/

    DIRECTIVE_PREPOSITIONS= /contains|in|#{MATH}/

    FILTER_WITH_VALUE_KEYWORDS = /date|replace_first|replace|remove_first|remove_first|remove|minus|times|divided_by|modulo|mod|split|join|truncatewords|truncate|prepend|append/

    FILTER_KEYWORDS = /#{FILTER_WITH_VALUE_KEYWORDS}|slugify|uri_escape|render|code|textilize|capitalize|downcase|upcase|first|last|sort|map|size|escape_once|escape|strip_html|strip_newlines|newline_to_br/

    SELECTOR_KEYWORDS = /tagged|in|with|snippet|script|content_item|folder|widget|wrapper|category|asset_folder|asset/

    LIQUID_DIRECTIVE_BLOCK = /
      {{1,2}%
      (.*?)
      %}{1,2}
    /x

    KEY_VALUE_REGEX = /(\w+)(:)(\w+|".*"|'.*?')/

    def setup
      @html_scanner = CodeRay.scanner(:html, :tokens => @tokens, :keep_tokens => true, :keep_state => true)
    end

    def scan_spaces(encoder)
      if match = scan(/\s+/)
        encoder.text_token match, :space
      end
    end

    def scan_string(encoder, substring)
      string_array = substring.match(/('|")(.+)('|")/)
      if string_array
        delimiter = string_array.captures[0]
        contents = string_array.captures[1]
        delimiter_2 = string_array.captures[2]

        encoder.begin_group :string
        encoder.text_token delimiter, :delimiter
        encoder.text_token contents, :contents
        encoder.text_token delimiter_2, :delimiter
        encoder.end_group :string
        
        true
      else
        false
      end
    end  

    def scan_csv_list(encoder, list)
      if !list.scan(/('.*?')(,)?/).empty?
        captured = list.scan(/('.*?')(,)?/)
      elsif !list.scan(/(".*?")(,)?/).empty?
        captured = list.scan(/(".*?")(,)?/)
      else
        captured = list.scan(/(\w)(,)?/)
      end
      captured.each do |value|
        unless scan_string(encoder, value[0])
          if value[0] =~ /^\d$/
            encoder.text_token value[0], :integer 
          else
            encoder.text_token value[0], :variable
          end
        end
        encoder.text_token(value[1], :delimiter) if value[1]
      end
    end

    def scan_key_of_key_value_pair(encoder, options, match)
      scan_spaces(encoder)
      key = scan(/\w+/)

      if key =~ /#{SELECTOR_KEYWORDS}/o
        encoder.text_token key, :directive
      else
        encoder.text_token key, :key
      end
    end

    def scan_value_of_key_value_pair(encoder, options, match)
      scan_spaces(encoder)
      first_character = peek(1)

      if values = scan(/\S+,\S+/)
        #match is set, so do nothing else
      elsif first_character == '"' || first_character == "'"
        values = scan(/#{first_character}.*?#{first_character}/)
      else
        values = scan(/\S+/)
      end
      #scan_spaces(encoder)
      scan_csv_list(encoder, values)
    end

    def scan_key_value_pair(encoder, options, match)
      scan_spaces(encoder)
      if match = check(/#{KEY_VALUE_REGEX}/o)
        scan_key_of_key_value_pair(encoder, options, match)

        delimiter = scan(/:/)
        encoder.text_token delimiter, :delimiter

        scan_value_of_key_value_pair(encoder, options, match)

        scan_spaces(encoder)
        true
      else
        false
      end
    end

    def scan_selector(encoder, options, match)
      scan_spaces(encoder)
      if  scan_key_value_pair(encoder, options, match)
        scan_spaces(encoder)
        if match = scan(/\+/)
          encoder.text_token match, :directive
        end
        scan_spaces(encoder)
        scan_selector(encoder, options, match)
      else
        false
      end
    end

    def scan_directive(encoder, options, match)
      encoder.text_token match, :tag
      scan_spaces(encoder)
      if match = scan(/#{DIRECTIVE_KEYWORDS}/o)
        encoder.text_token match, :directive
        scan_spaces(encoder)
        if match =~ /if|assign|assignlist|for|list|paginate/
          scan_selector(encoder, options, match)
          if match = scan(/\w+\.?\w*/)
            encoder.text_token match, :variable
          end
          scan_spaces(encoder)
          if match = scan(/#{DIRECTIVE_PREPOSITIONS}/o)
            encoder.text_token match, :keyword
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
      end
    end

    def scan_output_filters(encoder, options, match)
      encoder.text_token match, :keyword
      scan_spaces(encoder)
      if !scan_key_value_pair(encoder, options, match) and directive = scan(/#{FILTER_KEYWORDS}/)
        encoder.text_token directive, :directive
      end
      if next_filter = scan(/\s\|\s/)
        scan_output_filters(encoder, options, next_filter)
      end
    end

    def scan_output(encoder, options, match)
      encoder.text_token match, :tag
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
    end

    def scan_tokens(encoder, options)

      until eos?
        if (match = scan_until(/(?=({{2,3}|{{1,2}%))/) || scan_rest) and not match.empty?
          @html_scanner.tokenize(match, :tokens => encoder)
        scan_spaces(encoder)
        elsif match = scan(/{{1,2}%/)
          scan_directive(encoder, options, match) 
        elsif match = scan(/{{2,3}/)
          scan_output(encoder, options, match)
        else
          raise "Else-case reached." 
        end
      end
      encoder
    end
  end
end
end
