module CodeRay module Scanners
  
  # by Josh Goebel
  class SQL < Scanner

    register_for :sql
    
    RESERVED_WORDS = %w(
      and as avg before begin between by case collate columns create database
      databases delete distinct drop else end engine exists fields from full
      group having if index inner insert into is join key like not on or order
      outer primary prompt replace select set show table tables then trigger
      union update using values when where
    )
    
    PREDEFINED_TYPES = %w(
      bigint bin binary bit blob bool boolean char date datetime decimal
      double enum float hex int integer longblob longtext mediumblob mediumint
      mediumtext oct smallint text time timestamp tinyblob tinyint tinytext
      unsigned varchar year
    )
    
    PREDEFINED_FUNCTIONS = %w( sum cast abs pi count min max avg )
    
    DIRECTIVES = %w( auto_increment unique default charset )
    
    PREDEFINED_CONSTANTS = %w( null true false )
    
    IDENT_KIND = CaseIgnoringWordList.new(:ident).
      add(RESERVED_WORDS, :reserved).
      add(PREDEFINED_TYPES, :pre_type).
      add(PREDEFINED_CONSTANTS, :pre_constant).
      add(PREDEFINED_FUNCTIONS, :predefined).
      add(DIRECTIVES, :directive)
    
    ESCAPE = / [rbfntv\n\\\/'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} | . /mx
    UNICODE_ESCAPE =  / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x
    
    STRING_PREFIXES = /[xnb]|_\w+/i
    
    def scan_tokens tokens, options
      
      state = :initial
      string_type = nil
      string_content = ''
      
      until eos?
        
        kind = nil
        match = nil
        
        if state == :initial
          
          if scan(/ \s+ | \\\n /x)
            kind = :space
          
          elsif scan(/(?:--\s?|#).*/)
            kind = :comment
            
          elsif scan(%r! /\* (?: .*? \*/ | .* ) !mx)
            kind = :comment
            
          elsif scan(/ [-+*\/=<>;,!&^|()\[\]{}~%] | \.(?!\d) /x)
            kind = :operator
            
          elsif scan(/(#{STRING_PREFIXES})?([`"'])/o)
            prefix = self[1]
            string_type = self[2]
            tokens << [:open, :string]
            tokens << [prefix, :modifier] if prefix
            match = string_type
            state = :string
            kind = :delimiter
            
          elsif match = scan(/ @? [A-Za-z_][A-Za-z_0-9]* /x)
            kind = match[0] == ?@ ? :variable : IDENT_KIND[match.downcase]
            
          elsif scan(/0[xX][0-9A-Fa-f]+/)
            kind = :hex
            
          elsif scan(/0[0-7]+(?![89.eEfF])/)
            kind = :oct
            
          elsif scan(/(?>\d+)(?![.eEfF])/)
            kind = :integer
            
          elsif scan(/\d[fF]|\d*\.\d+(?:[eE][+-]?\d+)?|\d+[eE][+-]?\d+/)
            kind = :float
            
          else
            getch
            kind = :error
            
          end
          
        elsif state == :string
          if match = scan(/[^\\"'`]+/)
            string_content << match
            next
          elsif match = scan(/["'`]/)
            if string_type == match
              if peek(1) == string_type  # doubling means escape
                string_content << string_type << getch
                next
              end
              unless string_content.empty?
                tokens << [string_content, :content]
                string_content = ''
              end
              tokens << [matched, :delimiter]
              tokens << [:close, :string]
              state = :initial
              string_type = nil
              next
            else
              string_content << match
            end
            next
          elsif scan(/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox)
            unless string_content.empty?
              tokens << [string_content, :content]
              string_content = ''
            end
            kind = :char
          elsif match = scan(/ \\ . /mox)
            string_content << match
            next
          elsif scan(/ \\ | $ /x)
            unless string_content.empty?
              tokens << [string_content, :content]
              string_content = ''
            end
            kind = :error
            state = :initial
          else
            raise "else case \" reached; %p not handled." % peek(1), tokens
          end
          
        else
          raise 'else-case reached', tokens
          
        end
        
        match ||= matched
        unless kind
          raise_inspect 'Error token %p in line %d' %
            [[match, kind], line], tokens, state
        end
        raise_inspect 'Empty token', tokens unless match
        
        tokens << [match, kind]
        
      end
      tokens
      
    end
    
  end
  
end end