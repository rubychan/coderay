module CodeRay
module Scanners
  
  load :html
  load :ruby
  
  # Scanner for HTML ERB templates.
  class ERB < Scanner
    
    register_for :erb
    title 'HTML ERB Template'
    
    KINDS_NOT_LOC = HTML::KINDS_NOT_LOC
    
    ERB_RUBY_BLOCK = /
      <%(?!%)[=-]?
      (?>
        [^\-%]*    # normal*
        (?>        # special
          (?: %(?!>) | -(?!%>) )
          [^\-%]*  # normal*
        )*
      )
      (?: -?%> )?
    /x  # :nodoc:
    
    START_OF_ERB = /
      <%(?!%)
    /x  # :nodoc:
    
  protected
    
    def setup
      @ruby_scanner = CodeRay.scanner :ruby, :tokens => @tokens, :keep_tokens => true
      @html_scanner = CodeRay.scanner :html, :tokens => @tokens, :keep_tokens => true, :keep_state => true
    end
    
    def reset_instance
      super
      @html_scanner.reset
    end
    
    def scan_tokens encoder, options
      
      until eos?
        
        if (match = scan_until(/(?=#{START_OF_ERB})/o) || scan_rest) and not match.empty?
          @html_scanner.tokenize match, :tokens => encoder
          
        elsif match = scan(/#{ERB_RUBY_BLOCK}/o)
          start_tag = match[/\A<%[-=#]?/]
          end_tag = match[/-?%?>?\z/]
          encoder.begin_group :inline
          encoder.text_token start_tag, :inline_delimiter
          code = match[start_tag.size .. -1 - end_tag.size]
          if start_tag[/\A<%#/]
            encoder.text_token code, :comment
          else
            @ruby_scanner.tokenize code, :tokens => encoder
          end unless code.empty?
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
