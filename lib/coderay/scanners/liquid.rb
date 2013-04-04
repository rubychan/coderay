module CodeRay
module Scanners

  class Liquid < Scanner
    
    require 'csv'

    register_for :liquid
   
    DIRECTIVE_KEYWORDS = /endlist|list|endfor|for|endwrap|wrap|endif|if|endunless|unless|elsif|assignlist|assign|cycle|capture|end|capture|fill|endiflist|iflist|else/

    MATH = /==|=|!=|>|<=|<|>|\+/

    DIRECTIVE_PREPOSITIONS= /contains|in|#{MATH}/

    FILTER_WITH_VALUE_KEYWORDS = /date|replace_first|replace|remove_first|remove_first|remove|minus|times|divided_by|modulo|mod|split|join|truncatewords|truncate|prepend|append/

    FILTER_KEYWORDS = /#{FILTER_WITH_VALUE_KEYWORDS}|textilize|capitalize|downcase|upcase|first|last|sort|map|size|escape_once|escape|strip_html|strip_newlines|newline_to_br/

    SELECTOR_KEYWORDS = /in|with|snippet|script|content_item|folder|widget|wrapper|category|asset_folder|asset/

    LIQUID_DIRECTIVE_BLOCK = /
      {{1,2}%
      (.*?)
      %}{1,2}
    /x

    KEY_VALUE_REGEX = /(\w+)(:)(\w+|".*"|'.*?')/

    def setup
      @html_scanner = CodeRay.scanner(:html, tokens: @tokens, keep_tokens: true, keep_state: true)
    end

    def scan_spaces(encoder)
      if match = scan(/\s+/)
        encoder.text_token match, :space
      end
    end

    def scan_string(encoder, substring)
      if substring and string_array = substring.match(/('|")(.+)('|")/)
        delimiter = string_array.captures[0]
        contents = string_array.captures[1]
        delimiter_2 = string_array.captures[2]

        encoder.begin_group :string
        encoder.text_token delimiter, :delimiter
        encoder.text_token contents, :contents
        encoder.text_token delimiter, :delimiter
        encoder.end_group :string
        
        true
      else
        false
      end
    end  

    def scan_csv_list(encoder, list)
      CSV.parse(list) do |row|
        column_index = 0
        row.each do |value|
          column_index += 1
          unless scan_string(encoder, value)
            encoder.text_token value, :value
          end
          unless column_index >= row.length
            encoder.text_token ',', :delimiter 
          end
        end
      end
    end

    def scan_key_value_pair(encoder, options, match)
      scan_spaces(encoder)
      if match = check(/#{KEY_VALUE_REGEX}/)
        key = scan(/\w+/)
        delimiter, values = scan(/(:)(\S+)|(".*?")|('.*?')/).match(/(:)(\S+)|(".*?")|('.*?')/).captures

        if key =~ /#{SELECTOR_KEYWORDS}/
          encoder.text_token key, :directive
        else
          encoder.text_token key, :key
        end

        encoder.text_token delimiter, :delimiter
        scan_csv_list(encoder, values)        
        true
      else
        false
      end
    end

    def scan_selector(encoder, options, match)
      scan_spaces(encoder)
      if  scan_key_value_pair(encoder, options, match)
        scan_selector(encoder, options, match)
      else
        false
      end
    end

    def scan_directive(encoder, options, match)
      encoder.text_token match, :tag
      state = :liquid
      scan_spaces(encoder)
      if match = scan(/#{DIRECTIVE_KEYWORDS}/)
        encoder.text_token match, :directive
        scan_spaces(encoder)
        if match =~ /if|assign|assignlist|for|list/
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
      if !scan_key_value_pair(encoder, options, match) and directive = scan(/#{FILTER_KEYWORDS}/)
        encoder.text_token directive, :directive
      end
      if next_filter = scan(/\s\|\s/)
        scan_output_filters(encoder, options, next_filter)
      end
    end

    def scan_output(encoder, options, match)
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
      state = :initial

      until eos?
        if (match = scan_until(/(?=({{2,3}|{{1,2}%))/) || scan_rest) and not match.empty? and state != :liquid
          @html_scanner.tokenize(match, tokens: encoder)
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
