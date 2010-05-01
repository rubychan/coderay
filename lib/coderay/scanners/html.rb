module CodeRay
module Scanners

  # HTML Scanner
  # 
  # Alias: +xhtml+
  # 
  # See also: Scanners::XML
  class HTML < Scanner

    include Streamable
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
    
    def scan_tokens encoder, options
      
      state = @state
      plain_string_content = @plain_string_content
      
      until eos?
        
        if match = scan(/\s+/m)
          encoder.text_token match, :space
          
        else
          
          case state
          
          when :initial
            if match = scan(/<!--.*?-->/m)
              encoder.text_token match, :comment
            elsif match = scan(/<!DOCTYPE.*?>/m)
              encoder.text_token match, :doctype
            elsif match = scan(/<\?xml.*?\?>/m)
              encoder.text_token match, :preprocessor
            elsif match = scan(/<\?.*?\?>|<%.*?%>/m)
              encoder.text_token match, :comment
            elsif match = scan(/<\/[-\w.:]*>/m)
              encoder.text_token match, :tag
            elsif match = scan(/<[-\w.:]+>?/m)
              encoder.text_token match, :tag
              state = :attribute unless match[-1] == ?>
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
            if match = scan(/#{TAG_END}/)
              encoder.text_token match, :tag
              state = :initial
            elsif match = scan(/#{ATTR_NAME}/o)
              encoder.text_token match, :attribute_name
              state = :attribute_equal
            else
              encoder.text_token getch, :error
            end
            
          when :attribute_equal
            if match = scan(/=/)
              encoder.text_token match, :operator
              state = :attribute_value
            elsif match = scan(/#{ATTR_NAME}/o)
              encoder.text_token match, :attribute_name
            elsif match = scan(/#{TAG_END}/o)
              encoder.text_token match, :tag
              state = :initial
            else
              encoder.text_token getch, :error
              state = :attribute
            end
            
          when :attribute_value
            if match = scan(/#{ATTR_NAME}/o)
              encoder.text_token match, :attribute_value
              state = :attribute
            elsif match = scan(/["']/)
              encoder.begin_group :string
              state = :attribute_value_string
              plain_string_content = PLAIN_STRING_CONTENT[match]
              encoder.text_token match, :delimiter
            elsif scan(/#{TAG_END}/o)
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
