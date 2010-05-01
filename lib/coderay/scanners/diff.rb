module CodeRay
module Scanners
  
  # Scanner for output of the diff command.
  # 
  # Alias: +patch+
  class Diff < Scanner
    
    register_for :diff
    title 'diff output'
    
  protected
    
    require 'coderay/helpers/file_type'
    
    def scan_tokens encoder, options
      
      line_kind = nil
      state = :initial
      # TODO: Cache scanners
      content_lang = nil
      
      until eos?
        
        if match = scan(/\n/)
          if line_kind
            encoder.end_line line_kind
            line_kind = nil
          end
          encoder.text_token match, :space
          next
        end
        
        case state
        
        when :initial
          if match = scan(/--- |\+\+\+ |=+|_+/)
            encoder.begin_line line_kind = :head
            encoder.text_token match, :head
            if match = scan(/.*?(?=$|[\t\n\x00]|  \(revision)/)
              encoder.text_token match, :filename
              content_lang = FileType.fetch match, :plaintext
            end
            next unless match = scan(/.+/)
            encoder.text_token match, :plain
          elsif match = scan(/Index: |Property changes on: /)
            encoder.begin_line line_kind = :head
            encoder.text_token match, :head
            next unless match = scan(/.+/)
            encoder.text_token match, :plain
          elsif match = scan(/Added: /)
            encoder.begin_line line_kind = :head
            encoder.text_token match, :head
            next unless match = scan(/.+/)
            encoder.text_token match, :plain
            state = :added
          elsif match = scan(/\\ /)
            encoder.begin_line line_kind = :change
            encoder.text_token match, :change
            next unless match = scan(/.+/)
            encoder.text_token match, :plain
          elsif match = scan(/@@(?>[^@\n]*)@@/)
            if check(/\n|$/)
              encoder.begin_line line_kind = :change
            else
              encoder.begin_group :change
            end
            encoder.text_token match[0,2], :change
            encoder.text_token match[2...-2], :plain if match.size > 4
            encoder.text_token match[-2,2], :change
            encoder.end_group :change unless line_kind
            next unless match = scan(/.+/)
            CodeRay.scan match, content_lang, :tokens => encoder
            next
          elsif match = scan(/\+/)
            encoder.begin_line line_kind = :insert
            encoder.text_token match, :insert
            next unless match = scan(/.+/)
            CodeRay.scan match, content_lang, :tokens => encoder
            next
          elsif match = scan(/-/)
            encoder.begin_line line_kind = :delete
            encoder.text_token match, :delete
            next unless match = scan(/.+/)
            CodeRay.scan match, content_lang, :tokens => encoder
            next
          elsif match = scan(/ .*/)
            CodeRay.scan match, content_lang, :tokens => encoder
            next
          elsif match = scan(/.+/)
            encoder.begin_line line_kind = :comment
            encoder.text_token match, :plain
          else
            raise_inspect 'else case rached'
          end
        
        when :added
          if match = scan(/   \+/)
            encoder.begin_line line_kind = :insert
            encoder.text_token match, :insert
            next unless match = scan(/.+/)
            encoder.text_token match, :plain
          else
            state = :initial
            next
          end
        end
        
      end
      
      encoder.end_line line_kind if line_kind
      
      encoder
    end
    
  end
  
end
end
