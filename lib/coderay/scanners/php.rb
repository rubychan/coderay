class Regexp
  def |(other)
    Regexp.union(self, other)
  end
  def +(other)
    /#{self}#{other}/
  end
end
module CodeRay
module Scanners

  load :html
  
  # TODO: Complete rewrite. This scanner is buggy.
  class PHP < Scanner

    register_for :php
    file_extension 'php'

    def setup
      @html_scanner = CodeRay.scanner :html, :tokens => @tokens, :keep_tokens => true, :keep_state => true
    end

    def reset_instance
      super
      @html_scanner.reset
    end

    module Words
      ControlKeywords = %w!
        if else elseif while do for switch case default declare foreach as
        endif endwhile endfor endforeach endswitch enddeclare return break
        continue exit die try catch throw 
      !
      OtherKeywords = %w!
        function class extends implements instanceof parent self var const
        private public protected static abstract final global new echo include
        require include_once require_once eval print use unset isset empty
        interface list array clone null true false
      !

      SpecialConstants = %w! __LINE__ __FILE__ __CLASS__
        __METHOD__ __FUNCTION__ 
      !
      IdentKinds = WordList.new(:ident).
        add(ControlKeywords, :reserved).
        add(OtherKeywords, :pre_type).
        add(SpecialConstants, :pre_constant)
    end
    module RE
      def self.build_alternatives(array)
        Regexp.new(array.map { |s| Regexp.escape(s) }.join('|') , Regexp::IGNORECASE)
      end

      PHPStart = /
        <script language="php"> |
        <script language='php'> |
        <\?php                   |
        <\?(?!xml)               |
        <%
      /xi

      PHPEnd = %r!
        </script> |
        \?>        |
        %>
      !xi

      IChar = /[a-z0-9_\x80-\xFF]/i
      IStart = /[a-z_\x80-\xFF]/i
      Identifier = /#{IStart}#{IChar}*/
      Variable = /\$#{Identifier}/

      Typecasts = build_alternatives %w!
        float double real int integer bool boolean string array object null
      !.map{|s| "(#{s})"}
      OneLineComment1 = %r!//.*?(?=#{PHPEnd}|$)!
      OneLineComment2 = %r!#.*?(?=#{PHPEnd}|$)!
      OneLineComment = OneLineComment1 | OneLineComment2

      HereDoc = /<<</ + Identifier

      binops = %w!
        + - * / << >> & | ^ . % 
      !

      ComparisionOperator = build_alternatives %w$
        === !== == != <= >= 
      $
      IncDecOperator = build_alternatives %w! ++ -- !

      BinaryOperator = build_alternatives binops
      AssignOperator = build_alternatives binops.map {|s| "${s}=" }
      LogicalOperator = build_alternatives %w! and or xor not !
      ObjectOperator = build_alternatives %w! -> :: !
      OtherOperator = build_alternatives %w$ => = ? : [ ] ( ) ; , ~ ! @ > <$

      Operator = ComparisionOperator | IncDecOperator | LogicalOperator |
        ObjectOperator | AssignOperator | BinaryOperator | OtherOperator


      S = /\s+/
        
      Integer = /-?0x[0-9a-fA-F]/ | /-?\d+/
      Float = /-?(?:\d+\.\d*|\d*\.\d+)(?:e[+-]\d+)?/

    end

    def scan_tokens tokens, options
      states = [:php]
      heredocdelim = nil

      until eos?
        
        match = nil
        kind = nil
        
        case states.last
        when :html
          if scan RE::PHPStart
            kind = :delimiter
            states.pop
          else
            match = scan_until(/(?=#{RE::PHPStart})/o) || scan_until(/\z/)
            @html_scanner.tokenize match if not match.empty?
            kind = :space
            match = ''
          end
        
        when :php
          if scan RE::PHPEnd
            kind = :delimiter
            states.push :html

          elsif scan RE::S
            kind = :space

          elsif scan(/\/\*/)
            kind = :comment
            states.push :mlcomment

          elsif scan RE::OneLineComment 
            kind = :comment

          elsif match = scan(RE::Identifier)
            kind = Words::IdentKinds[match]
            if kind == :ident && check(/:(?!:)/) #&& tokens[-2][0] == 'case'
#             match << scan(/:/)
              kind = :label
            elsif kind == :ident and match =~ /^[A-Z]/
              kind = :constant
            end

          elsif scan RE::Integer 
            kind = :integer

          elsif scan RE::Float
            kind = :float

          elsif scan(/'/)
            kind = :delimiter
            states.push :sqstring

          elsif scan(/"/)
            kind = :delimiter
            states.push :dqstring

          elsif match = scan(RE::HereDoc)
            heredocdelim = match[RE::Identifier]
            kind = :delimiter
            # states.push :heredocstring

          elsif scan RE::Variable
            kind = :local_variable

          elsif scan(/\{/)
            kind = :operator
            states.push :php

          elsif scan(/\}/)
            if states.length == 1
              kind = :error
            else
              kind = :operator
              states.pop
            end

          elsif scan RE::Operator
            kind = :operator

          else
            getch
            kind = :error

          end

        when :mlcomment
          if scan(/(?:[^\n\r\f*]|\*(?!\/))+/)
            kind = :comment

          elsif scan(/\*\//)
            kind = :comment
            states.pop

          elsif scan(/[\r\n\f]+/)
            kind = :space
          end

        when :sqstring
          if scan(/[^\r\n\f'\\]+/)
            kind = :string
          elsif match = scan(/\\\\|\\'/)
            kind = :char
          elsif scan(/\\/)
            kind = :string
          elsif scan(/[\r\n\f ]+/)
            kind = :space
          elsif scan(/'/)
            kind = :delimiter
            states.pop
          end

        when :dqstring
#todo: $foo[bar] kind of stuff
          if scan(/[^\r\n\f"${\\]+/)
            kind = :string
          elsif scan(/\\x[a-fA-F]{2}/)
            kind = :char
          elsif scan(/\\\d{3}/)
            kind = :char
          elsif scan(/\\["\\abcfnrtyv]/)
            kind = :char
          elsif scan(/\\/)
            kind = :string
          elsif scan(/[\r\n\f]+/)
            kind = :space
          elsif match = scan(/#{RE::Variable}/o)
            kind = :local_variable
            if check(/\[#{RE::Identifier}\]/o)
              match << scan(/\[#{RE::Identifier}\]/o)
            elsif check(/\[/)
              match << scan(/\[#{RE::Identifier}?/o)
              kind = :error
            elsif check(/->#{RE::Identifier}/o)
              match << scan(/->#{RE::Identifier}/o)
            end
          elsif scan(/\{/)
            if check(/\$/)
              kind = :operator 
              states.push :php
            else
              kind = :string
            end
            match = '{'
          elsif scan(/\$\{#{RE::Identifier}\}/o)
            kind = :local_variable
          elsif scan(/\$/)
            kind = :string
          elsif scan(/"/)
            kind = :delimiter
            states.pop
          end
        else
          raise_inspect 'Unknown state!', tokens, states
        end

        match ||= matched
        if $DEBUG and not kind
          raise_inspect 'Error token %p in line %d' %
            [[match, kind], line], tokens, states
        end
        raise_inspect 'Empty token', tokens, states unless match

        tokens << [match, kind]

      end
      tokens

    end

  end

end
end
