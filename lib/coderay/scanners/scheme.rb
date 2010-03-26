module CodeRay
  module Scanners

    # Scheme scanner for CodeRay (by closure).
    # 
    # Thanks to murphy for putting CodeRay into public.
    class Scheme < Scanner
      
      # TODO: function defs
      # TODO: built-in functions
      
      register_for :scheme
      file_extension 'scm'

      CORE_FORMS = %w[
        lambda let let* letrec syntax-case define-syntax let-syntax
        letrec-syntax begin define quote if or and cond case do delay
        quasiquote set! cons force call-with-current-continuation call/cc
      ]  # :nodoc:
      
      IDENT_KIND = CaseIgnoringWordList.new(:ident).
        add(CORE_FORMS, :reserved)  # :nodoc:
      
      #IDENTIFIER_INITIAL = /[a-z!@\$%&\*\/\:<=>\?~_\^]/i
      #IDENTIFIER_SUBSEQUENT = /#{IDENTIFIER_INITIAL}|\d|\.|\+|-/
      #IDENTIFIER = /#{IDENTIFIER_INITIAL}#{IDENTIFIER_SUBSEQUENT}*|\+|-|\.{3}/
      IDENTIFIER = /[a-zA-Z!@$%&*\/:<=>?~_^][\w!@$%&*\/:<=>?~^.+\-]*|[+-]|\.\.\./  # :nodoc:
      DIGIT = /\d/  # :nodoc:
      DIGIT10 = /\d/  # :nodoc:
      DIGIT16 = /[0-9a-f]/i  # :nodoc:
      DIGIT8 = /[0-7]/  # :nodoc:
      DIGIT2 = /[01]/  # :nodoc:
      RADIX16 = /\#x/i  # :nodoc:
      RADIX8 = /\#o/i  # :nodoc:
      RADIX2 = /\#b/i  # :nodoc:
      RADIX10 = /\#d/i  # :nodoc:
      EXACTNESS = /#i|#e/i  # :nodoc:
      SIGN = /[\+-]?/  # :nodoc:
      EXP_MARK = /[esfdl]/i  # :nodoc:
      EXP = /#{EXP_MARK}#{SIGN}#{DIGIT}+/  # :nodoc:
      SUFFIX = /#{EXP}?/  # :nodoc:
      PREFIX10 = /#{RADIX10}?#{EXACTNESS}?|#{EXACTNESS}?#{RADIX10}?/  # :nodoc:
      PREFIX16 = /#{RADIX16}#{EXACTNESS}?|#{EXACTNESS}?#{RADIX16}/  # :nodoc:
      PREFIX8 = /#{RADIX8}#{EXACTNESS}?|#{EXACTNESS}?#{RADIX8}/  # :nodoc:
      PREFIX2 = /#{RADIX2}#{EXACTNESS}?|#{EXACTNESS}?#{RADIX2}/  # :nodoc:
      UINT10 = /#{DIGIT10}+#*/  # :nodoc:
      UINT16 = /#{DIGIT16}+#*/  # :nodoc:
      UINT8 = /#{DIGIT8}+#*/  # :nodoc:
      UINT2 = /#{DIGIT2}+#*/  # :nodoc:
      DECIMAL = /#{DIGIT10}+#+\.#*#{SUFFIX}|#{DIGIT10}+\.#{DIGIT10}*#*#{SUFFIX}|\.#{DIGIT10}+#*#{SUFFIX}|#{UINT10}#{EXP}/  # :nodoc:
      UREAL10 = /#{UINT10}\/#{UINT10}|#{DECIMAL}|#{UINT10}/  # :nodoc:
      UREAL16 = /#{UINT16}\/#{UINT16}|#{UINT16}/  # :nodoc:
      UREAL8 = /#{UINT8}\/#{UINT8}|#{UINT8}/  # :nodoc:
      UREAL2 = /#{UINT2}\/#{UINT2}|#{UINT2}/  # :nodoc:
      REAL10 = /#{SIGN}#{UREAL10}/  # :nodoc:
      REAL16 = /#{SIGN}#{UREAL16}/  # :nodoc:
      REAL8 = /#{SIGN}#{UREAL8}/  # :nodoc:
      REAL2 = /#{SIGN}#{UREAL2}/  # :nodoc:
      IMAG10 = /i|#{UREAL10}i/  # :nodoc:
      IMAG16 = /i|#{UREAL16}i/  # :nodoc:
      IMAG8 = /i|#{UREAL8}i/  # :nodoc:
      IMAG2 = /i|#{UREAL2}i/  # :nodoc:
      COMPLEX10 = /#{REAL10}@#{REAL10}|#{REAL10}\+#{IMAG10}|#{REAL10}-#{IMAG10}|\+#{IMAG10}|-#{IMAG10}|#{REAL10}/  # :nodoc:
      COMPLEX16 = /#{REAL16}@#{REAL16}|#{REAL16}\+#{IMAG16}|#{REAL16}-#{IMAG16}|\+#{IMAG16}|-#{IMAG16}|#{REAL16}/  # :nodoc:
      COMPLEX8 = /#{REAL8}@#{REAL8}|#{REAL8}\+#{IMAG8}|#{REAL8}-#{IMAG8}|\+#{IMAG8}|-#{IMAG8}|#{REAL8}/  # :nodoc:
      COMPLEX2 = /#{REAL2}@#{REAL2}|#{REAL2}\+#{IMAG2}|#{REAL2}-#{IMAG2}|\+#{IMAG2}|-#{IMAG2}|#{REAL2}/  # :nodoc:
      NUM10 = /#{PREFIX10}?#{COMPLEX10}/  # :nodoc:
      NUM16 = /#{PREFIX16}#{COMPLEX16}/  # :nodoc:
      NUM8 = /#{PREFIX8}#{COMPLEX8}/  # :nodoc:
      NUM2 = /#{PREFIX2}#{COMPLEX2}/  # :nodoc:
      NUM = /#{NUM10}|#{NUM16}|#{NUM8}|#{NUM2}/  # :nodoc:
      
    protected
      
      def scan_tokens tokens, options
        
        state = :initial
        ident_kind = IDENT_KIND
        
        until eos?
          kind = match = nil
          
          case state
          when :initial
            if scan(/ \s+ | \\\n /x)
              kind = :space
            elsif scan(/['\(\[\)\]]|#\(/)
              kind = :operator  # FIXME: was :operator_fat
            elsif scan(/;.*/)
              kind = :comment
            elsif scan(/#\\(?:newline|space|.?)/)
              kind = :char
            elsif scan(/#[ft]/)
              kind = :pre_constant
            elsif scan(/#{IDENTIFIER}/o)
              kind = ident_kind[matched]
            elsif scan(/\./)
              kind = :operator
            elsif scan(/"/)
              tokens << [:open, :string]
              state = :string
              tokens << ['"', :delimiter]
              next
            elsif scan(/#{NUM}/o) and not matched.empty?
              kind = :integer
            elsif getch
              kind = :error
            end
            
          when :string
            if scan(/[^"\\]+/) or scan(/\\.?/)
              kind = :content
            elsif scan(/"/)
              tokens << ['"', :delimiter]
              tokens << [:close, :string]
              state = :initial
              next
            else
              raise_inspect "else case \" reached; %p not handled." % peek(1),
                tokens, state
            end
            
          else
            raise "else case reached"
          end
          
          match ||= matched
          if $CODERAY_DEBUG and not kind
            raise_inspect 'Error token %p in line %d' %
              [[match, kind], line], tokens
          end
          raise_inspect 'Empty token', tokens, state unless match
          
          tokens << [match, kind]
          
        end
        
        if state == :string
          tokens << [:close, :string]
        end
        
        tokens
        
      end
    end
  end
end