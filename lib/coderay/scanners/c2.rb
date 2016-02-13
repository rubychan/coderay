module CodeRay
module Scanners
  
  # Scanner for C.
  class C2 < RuleBasedScanner
    
    register_for :c2
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
      on check_if(:in_preproc_line), %r/ \s*? \n \s* /x, :space, flag_off(:in_preproc_line), set(:label_expected, :label_expected_before_preproc_line)
      on %r/ \s+ | \\\n /x, :space
      
      on %r/ [-+*=<>?:;,!&^|()\[\]{}~%]+ | \/(?![\/*])=? | \.(?!\d) /x, :operator, set(:label_expected) { |match, case_expected| match =~ /[;\{\}]/ || case_expected && match =~ /:/ }, flag_off(:case_expected)
      
      on %r/ (?: case | default ) \b /x, :keyword, flag_on(:case_expected), flag_off(:label_expected)
      on check_if(:label_expected), check_unless(:in_preproc_line), %r/ [A-Za-z_][A-Za-z_0-9]*+ :(?!:) /x, kind { |match|
        kind = IDENT_KIND[match.chop]
        kind == :ident ? :label : kind
      }, set(:label_expected) { |kind| kind == :label }
      on %r/ [A-Za-z_][A-Za-z_0-9]* /x, kind { |match| IDENT_KIND[match] }, flag_off(:label_expected)
      
      on %r/(L)?(")/, push(:string), groups(:modifier, :delimiter)
      
      on %r/ L?' (?: [^\'\n\\] | \\ #{ESCAPE} )? '? /x,                   :char,    flag_off(:label_expected)
      on %r/0[xX][0-9A-Fa-f]+/,                                           :hex,     flag_off(:label_expected)
      on %r/(?:0[0-7]+)(?![89.eEfF])/,                                    :octal,   flag_off(:label_expected)
      on %r/(?:\d+)(?![.eEfF])L?L?/,                                      :integer, flag_off(:label_expected)
      on %r/\d[fF]?|\d*\.\d+(?:[eE][+-]?\d+)?[fF]?|\d+[eE][+-]?\d+[fF]?/, :float,   flag_off(:label_expected)
      
      on %r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .* ) !mx, :comment
      on %r/ \# \s* if \s* 0 /x, -> (match) {
        match << scan_until(/ ^\# (?:elif|else|endif) .*? $ | \z /mx) unless eos?
      }, :comment
      on %r/ \# [ \t]* include\b /x, :preprocessor, flag_on(:in_preproc_line), set(:label_expected_before_preproc_line, :label_expected), push_state(:include_expected)
      on %r/ \# [ \t]* \w* /x,       :preprocessor, flag_on(:in_preproc_line), set(:label_expected_before_preproc_line, :label_expected)
      
      on %r/\$/, :ident
    end
    
    state :string do
      on %r/[^\\\n"]+/, :content
      on %r/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mx, :char
      on %r/"/, :delimiter, pop,   flag_off(:label_expected)
      on %r/ \\ /x, pop, :error,   flag_off(:label_expected)
      on %r/ $ /x,  pop, flag_off(:label_expected), continue
    end
    
    state :include_expected do
      on %r/<[^>\n]+>?|"[^"\n\\]*(?:\\.[^"\n\\]*)*"?/, :include, pop_state
      on %r/ \s*? \n \s* /x, :space, pop_state
      on %r/\s+/, :space
      on %r//, pop_state, continue  # TODO: add otherwise method for this
    end
    
    scan_tokens_code = <<-"RUBY"
    def scan_tokens encoder, options#{ def_line = __LINE__; nil }
      state = @state
      label_expected = true
      case_expected = false
      label_expected_before_preproc_line = nil
      in_preproc_line = false
      
      states = [state]
      
      until eos?
        last_pos = pos
        case state
#{ @code.chomp.gsub(/^/, '        ') }
        else
          raise_inspect 'Unknown state: %p' % [state], encoder
        end
        
        raise_inspect 'nothing was consumed! states = %p' % [states], encoder if pos == last_pos
      end
      
      if state == :string
        encoder.end_group :string
      end
      
      encoder
    end
    RUBY
    
    if ENV['PUTS']
      puts CodeRay.scan(scan_tokens_code, :ruby).terminal
      puts "callbacks: #{callbacks.size}"
    end
    class_eval scan_tokens_code, __FILE__, def_line
  end
end
end
