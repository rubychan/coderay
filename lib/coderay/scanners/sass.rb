module CodeRay
module Scanners
  
  # A scanner for Sass.
  class Sass < CSS
    
    register_for :sass
    file_extension 'sass'
    
    SASS_FUNCTION = /(?:inline-image|linear-gradient|color-stops|mix|lighten|darken|rotate|image-url|image-width|image-height|sprite-url|sprite-path|sprite-file|sprite-map|sprite-position|sprite|unquote|join|round|ceil|floor|nth)/
    
    STRING_CONTENT_PATTERN = {
      "'" => /(?:[^\n\'\#]+|\\\n|#{RE::Escape}|#(?!\{))+/,
      '"' => /(?:[^\n\"\#]+|\\\n|#{RE::Escape}|#(?!\{))+/,
    }
    
  protected
    
    def setup
      @state = :initial
    end
    
    def scan_tokens encoder, options
      states = Array(options[:state] || @state)
      string_delimiter = nil
      
      until eos?
        
        if match = scan(/\s+/)
          encoder.text_token match, :space
          value_expected = false if match.index(/\n/)
          
        elsif states.last == :sass_inline && (match = scan(/\}/))
          encoder.text_token match, :inline_delimiter
          encoder.end_group :inline
          states.pop
        
        elsif case states.last
          when :initial, :media, :sass_inline
            if match = scan(/(?>#{RE::Ident})(?!\()/ox)
              encoder.text_token match, value_expected ? :value : (check(/.*:/) ? :key : :tag)
              next
            elsif !value_expected && (match = scan(/\*/))
              encoder.text_token match, :tag
              next
            elsif match = scan(RE::Class)
              encoder.text_token match, :class
              next
            elsif match = scan(RE::Id)
              encoder.text_token match, :id
              next
            elsif match = scan(RE::PseudoClass)
              encoder.text_token match, :pseudo_class
              next
            elsif match = scan(RE::AttributeSelector)
              # TODO: Improve highlighting inside of attribute selectors.
              encoder.text_token match[0,1], :operator
              encoder.text_token match[1..-2], :attribute_name if match.size > 2
              encoder.text_token match[-1,1], :operator if match[-1] == ?]
              next
            elsif match = scan(/(\=|@mixin +)#{RE::Ident}/o)
              encoder.text_token match, :function
              next
            elsif match = scan(/@media/)
              encoder.text_token match, :directive
              # states.push :media_before_name
              next
            end
          
          when :block
            if match = scan(/(?>#{RE::Ident})(?!\()/ox)
              if value_expected
                encoder.text_token match, :value
              else
                encoder.text_token match, :key
              end
              next
            end
            
          when :string
            if match = scan(STRING_CONTENT_PATTERN[string_delimiter])
              encoder.text_token match, :content
            elsif match = scan(/['"]/)
              encoder.text_token match, :delimiter
              encoder.end_group :string
              string_delimiter = nil
              states.pop
            elsif match = scan(/#\{/)
              encoder.begin_group :inline
              encoder.text_token match, :inline_delimiter
              states.push :sass_inline
            elsif match = scan(/ \\ | $ /x)
              encoder.end_group state
              encoder.text_token match, :error unless match.empty?
              states.pop
            else
              raise_inspect "else case #{string_delimiter} reached; %p not handled." % peek(1), encoder
            end
          
          else
            #:nocov:
            raise_inspect 'Unknown state', encoder
            #:nocov:
            
          end
          
        elsif match = scan(/\$#{RE::Ident}/o)
          encoder.text_token match, :variable
          next
        
        elsif match = scan(/&/)
          encoder.text_token match, :local_variable
          
        elsif match = scan(/\+#{RE::Ident}/o)
          encoder.text_token match, :include
          value_expected = true
          
        elsif match = scan(/\/\*(?:.*?\*\/|.*)|\/\/.*/)
          encoder.text_token match, :comment
          
        elsif match = scan(/#\{/)
          encoder.begin_group :inline
          encoder.text_token match, :inline_delimiter
          states.push :sass_inline
          
        elsif match = scan(/\{/)
          value_expected = false
          encoder.text_token match, :operator
          states.push :block
          
        elsif match = scan(/\}/)
          value_expected = false
          encoder.text_token match, :operator
          if states.last == :block || states.last == :media
            states.pop
          end
          
        elsif match = scan(/['"]/)
          encoder.begin_group :string
          string_delimiter = match
          encoder.text_token match, :delimiter
          if states.include? :sass_inline
            content = scan_until(/(?=#{string_delimiter}|\}|\z)/)
            encoder.text_token content, :content unless content.empty?
            encoder.text_token string_delimiter, :delimiter if scan(/#{string_delimiter}/)
            encoder.end_group :string
          else
            states.push :string
          end
          
        elsif match = scan(/#{SASS_FUNCTION}/o)
          encoder.text_token match, :predefined
          
        elsif match = scan(/#{RE::Function}/o)
          encoder.begin_group :function
          start = match[/^[-\w]+\(/]
          encoder.text_token start, :delimiter
          if match[-1] == ?)
            encoder.text_token match[start.size..-2], :content
            encoder.text_token ')', :delimiter
          else
            encoder.text_token match[start.size..-1], :content
          end
          encoder.end_group :function
          
        elsif match = scan(/(?: #{RE::Dimension} | #{RE::Percentage} | #{RE::Num} )/ox)
          encoder.text_token match, :float
          
        elsif match = scan(/#{RE::HexColor}/o)
          encoder.text_token match, :color
          
        elsif match = scan(/! *(?:important|optional)/)
          encoder.text_token match, :important
          
        elsif match = scan(/(?:rgb|hsl)a?\([^()\n]*\)?/)
          encoder.text_token match, :color
          
        elsif match = scan(/@else if\b|#{RE::AtKeyword}/)
          encoder.text_token match, :directive
          value_expected = true
          
        elsif match = scan(/ == | != | [-+*\/>~:;,.=()] /x)
          if match == ':'
            value_expected = true
          elsif match == ';'
            value_expected = false
          end
          encoder.text_token match, :operator
          
        else
          encoder.text_token getch, :error
          
        end
        
      end
      
      if options[:keep_state]
        @state = states
      end
      
      encoder
    end
    
  end
  
end
end
