module CodeRay
module Scanners
  
  # Scanner for C.
  class C4 < StateBasedScanner
    
    register_for :c4
    file_extension 'c'
    
    KEYWORDS = [
      'asm', 'break', 'case', 'continue', 'default', 'do',
      'else', 'enum', 'for', 'goto', 'if', 'return',
      'sizeof', 'struct', 'switch', 'typedef', 'union', 'while',
      'restrict',  # added in C99
    ]  # :nodoc:
    
    PREDEFINED_TYPES = [
      'int', 'long', 'short', 'char',
      'signed', 'unsigned', 'float', 'double',
      'bool', 'complex',  # added in C99
    ]  # :nodoc:
    
    PREDEFINED_CONSTANTS = [
      'EOF', 'NULL',
      'true', 'false',  # added in C99
    ]  # :nodoc:
    DIRECTIVES = [
      'auto', 'extern', 'register', 'static', 'void',
      'const', 'volatile',  # added in C89
      'inline',  # added in C99
    ]  # :nodoc:
    
    IDENT_KIND = WordList.new(:ident).
      add(KEYWORDS, :keyword).
      add(PREDEFINED_TYPES, :predefined_type).
      add(DIRECTIVES, :directive).
      add(PREDEFINED_CONSTANTS, :predefined_constant)  # :nodoc:
    
    ESCAPE = / [rbfntv\n\\'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} /x  # :nodoc:
    UNICODE_ESCAPE = / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x  # :nodoc:
    
  protected
    
    state :initial do
      check in_preproc_line? do
        skip %r/ \s*? \n \s* /x, :space do
          unset :in_preproc_line
          expect :label if label_expected_before_preproc_line?
        end
      end
      
      skip %r/ \s+ | \\\n /x, :space
      
      on %r/ [-+*=<>?:;,!&^|()\[\]{}~%]+ | \/(?![\/*])=? | \.(?!\d) /x, :operator do |match, case_expected|
        expect :label if match =~ /[;\{\}]/ || expected?(:case) && match =~ /:/
      end
      
      on %r/ (?: case | default ) \b /x, :keyword do
        expect :case
      end
      
      check label_expected?, !in_preproc_line? do
        on %r/ [A-Za-z_][A-Za-z_0-9]*+ :(?!:) /x, -> match {
          kind = IDENT_KIND[match.chop]
          kind == :ident ? :label : kind
        } do |kind|
          expect :label if kind == :label
        end
      end
      
      on %r/ [A-Za-z_][A-Za-z_0-9]* /x, IDENT_KIND
      
      on %r/(L)?(")/, push(:string), groups(:modifier, :delimiter)
      
      on %r/ L?' (?: [^\'\n\\] | \\ #{ESCAPE} )? '? /x, :char
      on %r/0[xX][0-9A-Fa-f]+/, :hex
      on %r/(?:0[0-7]+)(?![89.eEfF])/, :octal
      on %r/(?:\d+)(?![.eEfF])L?L?/, :integer
      on %r/\d[fF]?|\d*\.\d+(?:[eE][+-]?\d+)?[fF]?|\d+[eE][+-]?\d+[fF]?/, :float
      
      skip %r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .* ) !mx, :comment
      on %r/ \# \s* if \s* 0 /x, -> (match) {
        match << scan_until(/ ^\# (?:elif|else|endif) .*? $ | \z /mx) unless eos?
      }, :comment
      on %r/ \# [ \t]* include\b /x, :preprocessor, set(:in_preproc_line), set(:label_expected_before_preproc_line, :label_expected), push(:include)
      on %r/ \# [ \t]* \w* /x,       :preprocessor, set(:in_preproc_line), set(:label_expected_before_preproc_line, :label_expected)
      
      on %r/\$/, :ident
    end
    
    group_state :string do
      on %r/[^\\\n"]+/, :content
      on %r/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mx, :char
      on %r/"/, :delimiter, pop
      on %r/ \\ /x, pop, :error
      on %r/ $ /x,  pop
    end
    
    state :include do
      on %r/<[^>\n]+>?|"[^"\n\\]*(?:\\.[^"\n\\]*)*"?/, :include, pop
      on %r/ \s*? \n \s* /x, :space, pop
      on %r/\s+/, :space
      otherwise pop
    end
    
    protected
    
    def setup
      super
      
      @label_expected = true
      @case_expected = false
      @label_expected_before_preproc_line = nil
      @in_preproc_line = false
    end
    
    def close_groups encoder, states
      if states.last == :string
        encoder.end_group :string
      end
    end
    
  end

end
end
