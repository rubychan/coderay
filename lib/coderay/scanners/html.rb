module CodeRay
module Scanners

  # HTML Scanner
  # 
  # Alias: +xhtml+
  # 
  # See also: Scanners::XML
  class HTML < Scanner

    register_for :html
    
    KINDS_NOT_LOC = [
      :comment, :doctype, :preprocessor,
      :tag, :attribute_name, :operator,
      :attribute_value, :delimiter, :content,
      :plain, :entity, :error,
    ]  # :nodoc:
    
    ATTR_NAME = /[\w.:-]+/  # :nodoc:
    TAG_END = /\/?>/  # :nodoc:
    HEX = /[0-9a-fA-F]/  # :nodoc:
    ENTITY = /
      &
      (?:
        \w+
      |
        \#
        (?:
          \d+
        |
          x#{HEX}+
        )
      )
      ;
    /ox  # :nodoc:
    
    PLAIN_STRING_CONTENT = {
      "'" => /[^&'>\n]+/,
      '"' => /[^&">\n]+/,
    }  # :nodoc:
    
    def reset  # :nodoc:
      # FIXME: why not overwrite reset_instance?
      super
      @state = :initial
    end
    
  protected
    
    def setup
      @state = :initial
      @plain_string_content = nil
    end
    
    def scan_java_script encoder, code
      if code && !code.empty?
        @java_script_scanner ||= Scanners::JavaScript.new '', :keep_tokens => true
        # encoder.begin_group :inline
        @java_script_scanner.tokenize code, :tokens => encoder
        # encoder.end_group :inline
      end
    end
    
    def scan_tokens encoder, options
      
      state = @state
      plain_string_content = @plain_string_content
      in_tag = in_attribute = nil
      
      until eos?
        
        if match = scan(/\s+/m)
          encoder.text_token match, :space
          
        else
          
          case state
          
          when :initial
            case in_tag
            when 'script'
              if scan(/(\s*<!--)(?:(.*?)(-->)|(.*))/m)
                code = self[2] || self[4]
                closing = self[3]
                encoder.text_token self[1], :comment
              else
                code = scan_until(/(?=(?:\n\s*)?<\/script>)|\z/)
                closing = false
              end
              scan_java_script encoder, code
              encoder.text_token closing, :comment if closing
            end
            next if eos?
            if match = scan(/<!--(?:.*?-->|.*)/m)
              encoder.text_token match, :comment
            elsif match = scan(/<!DOCTYPE(?:.*?>|.*)/m)
              encoder.text_token match, :doctype
            elsif match = scan(/<\?xml(?:.*?\?>|.*)/m)
              encoder.text_token match, :preprocessor
            elsif match = scan(/<\?(?:.*?\?>|.*)|<%(?:.*?%>|.*)/m)
              encoder.text_token match, :comment
            elsif match = scan(/<\/[-\w.:]*>?/m)
              encoder.text_token match, :tag
              in_tag = nil
            elsif match = scan(/<(?:(script)|[-\w.:]+)(>)?/m)
              encoder.text_token match, :tag
              in_tag = self[1]
              state = :attribute unless self[2]
            elsif match = scan(/[^<>&]+/)
              encoder.text_token match, :plain
            elsif match = scan(/#{ENTITY}/ox)
              encoder.text_token match, :entity
            elsif match = scan(/[<>&]/)
              encoder.text_token match, :error
            else
              raise_inspect '[BUG] else-case reached with state %p' % [state], encoder
            end
            
          when :attribute
            if match = scan(/#{TAG_END}/o)
              encoder.text_token match, :tag
              in_attribute = nil
              state = :initial
            elsif match = scan(/#{ATTR_NAME}/o)
              if match.downcase == 'onclick'
                in_attribute = 'script'
              end
              encoder.text_token match, :attribute_name
              state = :attribute_equal
            else
              encoder.text_token getch, :error
            end
            
          when :attribute_equal
            if match = scan(/=/)
              encoder.text_token match, :operator
              state = :attribute_value
            elsif scan(/#{ATTR_NAME}/o) || scan(/#{TAG_END}/o)
              state = :attribute
              next
            else
              encoder.text_token getch, :error
              state = :attribute
            end
            
          when :attribute_value
            if match = scan(/#{ATTR_NAME}/o)
              encoder.text_token match, :attribute_value
              state = :attribute
            elsif match = scan(/["']/)
              if in_attribute == 'script'
                encoder.begin_group :inline
                encoder.text_token match, :inline_delimiter
                if scan(/javascript:\s*/)
                  encoder.text_token matched, :comment
                end
                code = scan_until(match == '"' ? /(?="|\z)/ : /(?='|\z)/)
                scan_java_script encoder, code
                match = scan(/["']/)
                encoder.text_token match, :inline_delimiter if match
                encoder.end_group :inline
                state = :attribute
                in_attribute = nil
              else
                encoder.begin_group :string
                state = :attribute_value_string
                plain_string_content = PLAIN_STRING_CONTENT[match]
                encoder.text_token match, :delimiter
              end
            elsif match = scan(/#{TAG_END}/o)
              encoder.text_token match, :tag
              state = :initial
            else
              encoder.text_token getch, :error
            end
            
          when :attribute_value_string
            if match = scan(plain_string_content)
              encoder.text_token match, :content
            elsif match = scan(/['"]/)
              encoder.text_token match, :delimiter
              encoder.end_group :string
              state = :attribute
            elsif match = scan(/#{ENTITY}/ox)
              encoder.text_token match, :entity
            elsif match = scan(/&/)
              encoder.text_token match, :content
            elsif match = scan(/[\n>]/)
              encoder.end_group :string
              state = :initial
              encoder.text_token match, :error
            end
            
          else
            raise_inspect 'Unknown state: %p' % [state], encoder
            
          end
          
        end
        
      end
      
      if options[:keep_state]
        @state = state
        @plain_string_content = plain_string_content
      else
        if state == :attribute_value_string
          encoder.end_group :string
        end
      end
      
      encoder
    end
    
  end
  
end
end
