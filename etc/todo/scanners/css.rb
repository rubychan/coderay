module CodeRay
module Scanners

  class Css < Scanner

    register_for :css

    module RE
      NonASCII = /[\x80-\xFF]/
      Hex = /[0-9a-fA-F]/
      Unicode = /\\#{Hex}{1,6}(?:\r\n|\s)?/ # differs from standard because it allows uppercase hex too
      Escape = /#{Unicode}|\\[^\r\n\f0-9a-fA-F]/
      NMChar = /[_a-zA-Z0-9-]|#{NonASCII}|#{Escape}/
      NMStart = /[_a-zA-Z]|#{NonASCII}|#{Escape}/
      NL = /\r\n|\r|\n|\f/
      String1 = /"(?:[^\n\r\f\\"]|\\#{NL}|#{Escape})*"/
      String2 = /'(?:[^\n\r\f\\']|\\#{NL}|#{Escape})*'/
      String = /#{String1}|#{String2}/
      Invalid1 = /"(?:[^\n\r\f\\"]|\\#{NL}|#{Escape})*/
      Invalid2 = /'(?:[^\n\r\f\\']|\\#{NL}|#{Escape})*/
      Invalid = /#{Invalid1}|#{Invalid2}/
      W = /\s+/
      S = W

      HexColor = /#(?:#{Hex}{6}|#{Hex}{3})/
      Color = /#{HexColor}/

      Num = /-?(?:[0-9]+|[0-9]*\.[0-9]+)/
      Name = /#{NMChar}+/
      Ident = /-?#{NMStart}#{NMChar}*/
      AtKeyword = /@#{Ident}/
      Percentage = /#{Num}%/

      reldimensions = %w[em ex px]
      absdimensions = %w[in cm mm pt pc]
      Unit = /#{(reldimensions + absdimensions).join('|')}/

      Dimension = /#{Num}#{Unit}/

      Comment = %r! /\* (?: .*? \*/ | .* ) !mx
      URL = /url\((?:[^)\n\r\f]|\\\))*\)/


      Id = /##{Name}/
      Class = /\.#{Name}/

    end

    def scan_tokens tokens, options
      states = [:initial]
      i = 0
      until eos?

        kind = nil
        match = nil

        if states.last == :comment
          if scan /(?:[^\n\r\f*]|\*(?!\/))+/
            kind = :comment
            
          elsif scan /\*\//
            kind = :comment
            states.pop

          elsif scan RE::S
            kind = :space
          end

        elsif scan RE::S
          kind = :space

        elsif scan /\/\*/
          kind = :comment
          states.push :comment

        elsif scan RE::String
          kind = :string

        elsif scan RE::AtKeyword
          kind = :reserved

        elsif scan RE::Invalid
          kind = :error

        elsif scan RE::URL
          kind = :string

        elsif scan RE::Dimension
          kind = :float

        elsif scan RE::Percentage
          kind = :float

        elsif scan RE::Num
          kind = :float

        elsif scan /\{/
          kind = :operator
          states.push :block

        elsif scan /\}/
          if states.last == :block
            kind = :operator
            states.pop
          else
            kind = :error
          end

        elsif 
          case states.last
          when :initial

            if scan RE::Class
              kind = :class

            elsif scan RE::Id 
              kind = :constant

            elsif scan RE::Ident
              kind = :label

            elsif scan RE::Name
              kind = :identifier

            end

          when :block 
            if scan RE::Color
              kind = :color

            elsif scan RE::Ident
              kind = :definition

            elsif scan RE::Name
              kind = :symbol

            end

          else
            raise_inspect 'Unknown state', tokens

          end

        elsif scan(/ [-+*\/=<>?:;,!&^|()\[\]{}~%]+ | \.(?!\d) /x)
          kind = :operator

        else
          getch
          kind = :error

        end

        match ||= matched
        if $DEBUG and not kind
          raise_inspect 'Error token %p in line %d' %
            [[match, kind], line], tokens
        end
        raise_inspect 'Empty token', tokens unless match

        tokens << [match, kind]

      end

      tokens
    end

  end

end
end
