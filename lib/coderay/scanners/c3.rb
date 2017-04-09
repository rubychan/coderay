module CodeRay
module Scanners
  
  # Scanner for C.
  class C3 < RuleBasedScanner
    
    register_for :c3
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
      on check_if(:in_preproc_line), %r/ \s*? \n \s* /x, :space, unset(:in_preproc_line), set(:label_expected, :label_expected_before_preproc_line)
      on %r/ \s+ | \\\n /x, :space
      
      on %r/ [-+*=<>?:;,!&^|()\[\]{}~%]+ | \/(?![\/*])=? | \.(?!\d) /x, :operator, set(:label_expected) { |match, case_expected|
        match =~ /[;\{\}]/ || case_expected && match =~ /:/
      }, unset(:case_expected)
      
      on %r/ (?: case | default ) \b /x, :keyword, set(:case_expected), unset(:label_expected)
      on check_if(:label_expected), check_unless(:in_preproc_line), %r/ [A-Za-z_][A-Za-z_0-9]*+ :(?!:) /x, kind { |match|
        kind = IDENT_KIND[match.chop]
        kind == :ident ? :label : kind
      }, set(:label_expected) { |kind| kind == :label }
      on %r/ [A-Za-z_][A-Za-z_0-9]* /x, kind { |match| IDENT_KIND[match] }, unset(:label_expected)
      
      on %r/(L)?(")/, push(:string), groups(:modifier, :delimiter)
      
      on %r/ L?' (?: [^\'\n\\] | \\ #{ESCAPE} )? '? /x,                   :char,    unset(:label_expected)
      on %r/0[xX][0-9A-Fa-f]+/,                                           :hex,     unset(:label_expected)
      on %r/(?:0[0-7]+)(?![89.eEfF])/,                                    :octal,   unset(:label_expected)
      on %r/(?:\d+)(?![.eEfF])L?L?/,                                      :integer, unset(:label_expected)
      on %r/\d[fF]?|\d*\.\d+(?:[eE][+-]?\d+)?[fF]?|\d+[eE][+-]?\d+[fF]?/, :float,   unset(:label_expected)
      
      on %r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .* ) !mx, :comment
      on %r/ \# \s* if \s* 0 /x, -> (match) {
        match << scan_until(/ ^\# (?:elif|else|endif) .*? $ | \z /mx) unless eos?
      }, :comment
      on %r/ \# [ \t]* include\b /x, :preprocessor, set(:in_preproc_line), set(:label_expected_before_preproc_line, :label_expected), push_state(:include_expected)
      on %r/ \# [ \t]* \w* /x,       :preprocessor, set(:in_preproc_line), set(:label_expected_before_preproc_line, :label_expected)
      
      on %r/\$/, :ident
    end
    
    state :string do
      on %r/[^\\\n"]+/, :content
      on %r/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mx, :char
      on %r/"/, :delimiter, pop, unset(:label_expected)
      on %r/ \\ /x, pop, :error, unset(:label_expected)
      on %r/ $ /x,  pop, unset(:label_expected)
    end
    
    state :include_expected do
      on %r/<[^>\n]+>?|"[^"\n\\]*(?:\\.[^"\n\\]*)*"?/, :include, pop_state
      on %r/ \s*? \n \s* /x, :space, pop_state
      on %r/\s+/, :space
      on %r//, pop_state  # TODO: add otherwise method for this
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
