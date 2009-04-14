module CodeRay
module Scanners
  
  # Bases on pygments' PythonLexer, see
  # http://dev.pocoo.org/projects/pygments/browser/pygments/lexers/agile.py.
  class Python < Scanner
    
    include Streamable
    
    register_for :python
    file_extension 'py'
    
    KEYWORDS = [
      'and', 'as', 'assert', 'break', 'class', 'continue', 'def',
      'del', 'elif', 'else', 'except', 'finally', 'for',
      'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'not',
      'or', 'pass', 'raise', 'return', 'try', 'while', 'with', 'yield',
      'exec', 'print',  # gone in Python 3
      'nonlocal',  # new in Python 3
    ]
    
    PREDEFINED_METHODS_AND_TYPES = %w[
      __import__ abs all any apply basestring bin bool buffer
      bytearray bytes callable chr classmethod cmp coerce compile
      complex delattr dict dir divmod enumerate eval execfile exit
      file filter float frozenset getattr globals hasattr hash hex id
      input int intern isinstance issubclass iter len list locals
      long map max min next object oct open ord pow property range
      raw_input reduce reload repr reversed round set setattr slice
      sorted staticmethod str sum super tuple type unichr unicode
      vars xrange zip
    ]
    
    PREDEFINED_EXCEPTIONS = %w[
      ArithmeticError AssertionError AttributeError
      BaseException DeprecationWarning EOFError EnvironmentError
      Exception FloatingPointError FutureWarning GeneratorExit IOError
      ImportError ImportWarning IndentationError IndexError KeyError
      KeyboardInterrupt LookupError MemoryError NameError
      NotImplemented NotImplementedError OSError OverflowError
      OverflowWarning PendingDeprecationWarning ReferenceError
      RuntimeError RuntimeWarning StandardError StopIteration
      SyntaxError SyntaxWarning SystemError SystemExit TabError
      TypeError UnboundLocalError UnicodeDecodeError
      UnicodeEncodeError UnicodeError UnicodeTranslateError
      UnicodeWarning UserWarning ValueError Warning ZeroDivisionError
    ]
    
    PREDEFINED_VARIABLES_AND_CONSTANTS = [
      'False', 'True', 'None', # "keywords" since Python 3
      'self', 'Ellipsis', 'NotImplemented',
    ]
    
    IDENT_KIND = WordList.new(:ident).
      add(KEYWORDS, :keyword).
      add(PREDEFINED_METHODS_AND_TYPES, :predefined).
      add(PREDEFINED_VARIABLES_AND_CONSTANTS, :pre_constant).
      add(PREDEFINED_EXCEPTIONS, :exception)
    
    ESCAPE = / [rbfnrtv\n\\'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} /x
    UNICODE_ESCAPE =  / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x
    
    OPERATOR = /
      \.\.\. |          # ellipsis
      \.(?!\d) |        # dot but not decimal point
      [,;:()\[\]{}] |   # simple delimiters
      \/\/=? | \*\*=? | # special math
      [-+*\/%&|^]=? |   # ordinary math and binary logic
      [~@] |            # whatever
      <<=? | >>=? | [<>=]=? | !=  # comparison and assignment
    /x
    
    def scan_tokens tokens, options
      
      state = :initial
      string_delimiter = nil
      import_clause = class_name_follows = last_token_dot = false
      
      until eos?
        
        kind = nil
        match = nil
        
        case state
        
        when :initial
          
          if match = scan(/ [ \t]+ | \\?\n /x)
            tokens << [match, :space]
            next
          
          elsif match = scan(/ \# [^\n]* /mx)
            tokens << [match, :comment]
            next
          
          elsif scan(/#{OPERATOR}/ox)
            kind = :operator
          
          elsif match = scan(/(?i:(u?r?))?("""|"|'''|')/)
            tokens << [:open, :string]
            string_delimiter = self[2]
            string_raw = false
            modifiers = self[1]
            unless modifiers.empty?
              string_raw = !!modifiers.index(?r)
              tokens << [modifiers, :modifier]
              match = string_delimiter
            end
            state = :string
            kind = :delimiter
          
          elsif match = scan(/[[:alpha:]_][[:alnum:]_]*/ux)
            kind = IDENT_KIND[match]
            # TODO: handle class, def, from, import
            # TODO: handle print, exec used as functions in Python 3 code
            kind = :ident if last_token_dot
          
          elsif scan(/0[xX][0-9A-Fa-f]+/)
            kind = :hex
          
          elsif scan(/(?:0[0-7]+)(?![89.eEfF])/)
            kind = :oct
          
          # TODO: Complex numbers
          elsif scan(/(?:\d+)(?![.eEfF])/)
            kind = :integer
          
          # TODO: Floats
          elsif scan(/\d[fF]?|\d*\.\d+(?:[eE][+-]?\d+)?[fF]?|\d+[eE][+-]?\d+[fF]?/)
            kind = :float
          
          else
            getch
            kind = :error
          
          end
        
        when :string
          # TODO: cache Regexps
          if scan(Regexp.union(string_delimiter))
            tokens << [matched, :delimiter]
            tokens << [:close, :string]
            state = :initial
            next
          elsif string_delimiter.size == 3 && scan(/\n/)
            kind = :content
          elsif scan(/ [^\\\n]+? (?= \\ | $ | #{Regexp.escape(string_delimiter)} ) /x)
            kind = :content
          elsif !string_raw && scan(/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox)
            kind = :char
          elsif scan(/ \\ . /x)
            kind = :content
          elsif scan(/ \\ | $ /x)
            tokens << [:close, :string]
            kind = :error
            state = :initial
          else
            raise_inspect "else case \" reached; %p not handled." % peek(1), tokens, state
          end
        
        when :include_expected
          if scan(/<[^>\n]+>?|"[^"\n\\]*(?:\\.[^"\n\\]*)*"?/)
            kind = :include
            state = :initial
          
          elsif match = scan(/\s+/)
            kind = :space
            state = :initial if match.index ?\n
          
          else
            getch
            kind = :error
          
          end
          
        else
          raise_inspect 'Unknown state', tokens, state
        
        end

        match ||= matched
        if $DEBUG and not kind
          raise_inspect 'Error token %p in line %d' %
            [[match, kind], line], tokens, state
        end
        raise_inspect 'Empty token', tokens, state unless match
        
        last_token_dot = match == '.'
        
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
