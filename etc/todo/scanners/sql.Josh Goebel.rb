# by Josh Goebel
module CodeRay module Scanners
  
  class SQL < Scanner

    register_for :sql
    
    RESERVED_WORDS = [
      'create','table','index','trigger','drop',
      'primary','key',
      'select','insert','update','vacuum','delete','merge','replace','truncate',
      'into','on','from','values',
      'after','before',
      'and','or',
      'count','min','max','group','order','by','avg',
      'where','join','inner','outer','unique','union',
      'transaction',
      'begin','end',
    ]
    
    PREDEFINED_TYPES = [
      'char','varchar','enum','set','binary',
      'text','tinytext','mediumtext','longtext',
      'blob','tinyblob','mediumblob','longblob',
      'timestamp','date','time','datetime','year',
      'double','decimal','float',
      'int','integer','tinyint','mediumint','bigint',
      'bit','bool','boolean'
    ]

    PREDEFINED_CONSTANTS = [
      'null', 'true', 'false', 'not'
    ]
    
    SQL_KIND= CaseIgnoringWordList.new(:ident).
      add(RESERVED_WORDS, :reserved).
      add(PREDEFINED_TYPES, :pre_type).
      add(PREDEFINED_CONSTANTS, :pre_constant)
    
    IDENT_KIND = WordList.new(:ident)

    ESCAPE = / [rbfnrtv\n\\\/'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} /x
    UNICODE_ESCAPE =  / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x

    def scan_tokens tokens, options

      state = :initial
      string_type = nil

      until eos?

        kind = :error
        match = nil

        if state == :initial
          
          if scan(/ ^ -- .* $ /x)
            kind = :comment
          elsif scan(/ \s+ | \\\n /x)
            kind = :space
            
          elsif scan(%r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .* ) !mx)
            kind = :comment

          elsif match = scan(/ \# \s* if \s* 0 /x)
            match << scan_until(/ ^\# (?:elif|else|endif) .*? $ | \z /xm) unless eos?
            kind = :comment
            
          elsif scan(/ [-+*\/=<>?:;,!&^|()\[\]{}~%] | \.(?!\d) /x)
            kind = :operator
            
          elsif match = scan(/ [A-Za-z_][A-Za-z_0-9]* /x)
            kind = SQL_KIND[match.downcase]
            kind = IDENT_KIND[match] if kind.nil?
            
          elsif match = scan(/[`"']/)
            tokens << [:open, :string]
            string_type = matched
            state = :string
            kind = :delimiter
    
          elsif scan(/0[xX][0-9A-Fa-f]+/)
            kind = :hex
            
          elsif scan(/(?:0[0-7]+)(?![89.eEfF])/)
            kind = :oct
            
          elsif scan(/(?:\d+)(?![.eEfF])/)
            kind = :integer
            
          elsif scan(/\d[fF]?|\d*\.\d+(?:[eE][+-]?\d+)?[fF]?|\d+[eE][+-]?\d+[fF]?/)
            kind = :float

          else
            getch
          end
  
        elsif state == :string
          if scan(/[^\\"'`]+/)
            kind = :content
          elsif scan(/["'`]/)
            if string_type==matched
              tokens << [matched, :delimiter]
              tokens << [:close, :string]
              state = :initial
              string_type=nil
              next
            else
              kind = :content
            end
          elsif scan(/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox)
            kind = :content
          elsif scan(/ \\ | $ /x)
            kind = :error
            state = :initial
          else
            raise "else case \" reached; %p not handled." % peek(1), tokens
          end

        else
          raise 'else-case reached', tokens
          
        end
        
        match ||= matched
#        raise [match, kind], tokens if kind == :error
        
        tokens << [match, kind]
        
      end
#      RAILS_DEFAULT_LOGGER.info tokens.inspect
      tokens
      
    end

  end

end end