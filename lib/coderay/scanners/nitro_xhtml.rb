module CodeRay
module Scanners
  
  load :html
  load :ruby
  
  # Nitro XHTML Scanner
  # 
  # Alias: +nitro+
  class NitroXHTML < Scanner
    
    register_for :nitro_xhtml
    file_extension :xhtml
    title 'Nitro XHTML'
    
    KINDS_NOT_LOC = HTML::KINDS_NOT_LOC
    
    NITRO_RUBY_BLOCK = /
      <\?r
      (?>
        [^\?]*
        (?> \?(?!>) [^\?]* )*
      )
      (?: \?> )?
    |
      <ruby>
      (?>
        [^<]*
        (?> <(?!\/ruby>) [^<]* )*
      )
      (?: <\/ruby> )?
    |
      <%
      (?>
        [^%]*
        (?> %(?!>) [^%]* )*
      )
      (?: %> )?
    /mx  # :nodoc:
    
    NITRO_VALUE_BLOCK = /
      \#
      (?:
        \{
        [^{}]*
        (?>
          \{ [^}]* \}
          (?> [^{}]* )
        )*
        \}?
      | \| [^|]* \|?
      | \( [^)]* \)?
      | \[ [^\]]* \]?
      | \\ [^\\]* \\?
      )
    /x  # :nodoc:
    
    NITRO_ENTITY = /
      % (?: \#\d+ | \w+ ) ;
    /  # :nodoc:
    
    START_OF_RUBY = /
      (?=[<\#%])
      < (?: \?r | % | ruby> )
    | \# [{(|]
    | % (?: \#\d+ | \w+ ) ;
    /x  # :nodoc:
    
    CLOSING_PAREN = Hash.new { |h, p| h[p] = p }  # :nodoc:
    CLOSING_PAREN.update( {
      '(' => ')',
      '[' => ']',
      '{' => '}',
    } )
    
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
        
        if (match = scan_until(/(?=#{START_OF_RUBY})/o) || scan_rest) and not match.empty?
          @html_scanner.tokenize match
          
        elsif match = scan(/#{NITRO_VALUE_BLOCK}/o)
          start_tag = match[0,2]
          delimiter = CLOSING_PAREN[start_tag[1,1]]
          end_tag = match[-1,1] == delimiter ? delimiter : ''
          encoder.begin_group :inline
          encoder.text_token start_tag, :inline_delimiter
          code = match[start_tag.size .. -1 - end_tag.size]
          @ruby_scanner.tokenize code, :tokens => encoder
          encoder.text_token end_tag, :inline_delimiter unless end_tag.empty?
          encoder.end_group :inline
          
        elsif match = scan(/#{NITRO_RUBY_BLOCK}/o)
          start_tag = '<?r'
          end_tag = match[-2,2] == '?>' ? '?>' : ''
          encoder.begin_group :inline
          encoder.text_token start_tag, :inline_delimiter
          code = match[start_tag.size .. -(end_tag.size)-1]
          @ruby_scanner.tokenize code, :tokens => encoder
          encoder.text_token end_tag, :inline_delimiter unless end_tag.empty?
          encoder.end_group :inline
          
        elsif entity = scan(/#{NITRO_ENTITY}/o)
          encoder.text_token entity, :entity
          
        elsif scan(/%/)
          encoder.text_token matched, :error
          
        else
          raise_inspect 'else-case reached!', encoder
          
        end
        
      end
      
      encoder
      
    end
    
  end
  
end
end
