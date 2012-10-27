module CodeRay
  module Scanners

    # by Eric Thomas
    class Tcl < Scanner

      register_for :tcl

      # Taken from http://www.xilinx.com/itp/xilinx10/isehelp/ite_r_tcl_reserved_words.htm
      RESERVED_WORDS = %w(after append array auto_execok auto_import auto_load
                          auto_load_index auto_qualify binary bgerrro break
                          catch cd clock close concat continue dde default
                          else elseif encoding eof error eval exec exit expr
                          fblocked fconfigure fcopy file fileevent flush for
                          foreach format gets glob global history if incr
                          interp join lappend lindex list llength load lrange
                          lrange lreplace lsearch lsort namespace open package
                          pid pkg_mkIndex proc puts pwd read regexp regsub
                          rename resource return scan seek set socket source
                          split string subst switch tclLog tell time trace
                          unknown unset update uplevel upvar vwait while)

      PREDEFINED_TYPES = %w(variable)

      # should we include 0 or 1?
      PREDEFINED_CONSTANTS = %w(true false yes no on off 1 0)

      IDENT_KIND = WordList.new(:ident).
        add(RESERVED_WORDS, :reserved).
        add(PREDEFINED_TYPES, :pre_type).
        add(PREDEFINED_CONSTANTS, :pre_constant)

      ESCAPE = / [rbfntv\n\\'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} /x
      UNICODE_ESCAPE =  / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x

      def scan_tokens tokens, options
        state = :initial

        until eos?
          kind = nil
          match = nil

          case state
          when :initial

            if scan(/ \s+ | \\\n /x)
              kind = :space

            elsif scan(/#.*/)
               kind = :comment

            elsif scan(/ [-+*\/=<>?:;,!&^|()\[\]{}~%]+ | \.(?!\d) /x)
              kind = :operator

            elsif scan(/\$\S+/)
              kind = :variable

            elsif match = scan(/ [A-Za-z_][A-Za-z_0-9]* /x)
              kind = IDENT_KIND[match]
              if kind == :ident and check(/:(?!:)/)
                match << scan(/:/)
                kind = :label
              end

            elsif match = scan(/L?"/)
              tokens << [:open, :string]
              if match[0] == ?L
                tokens << ['L', :modifier]
                match = '"'
              end
              state = :string
              kind = :delimiter

            elsif scan(/ L?' (?: [^\'\n\\] | \\ #{ESCAPE} )? '? /ox)
              kind = :char

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
              kind = :error

            end

          when :string
            if scan(/[^\\\n"]+/)
              kind = :content
            elsif scan(/"/)
              tokens << ['"', :delimiter]
              tokens << [:close, :string]
              state = :initial
              next
            elsif scan(/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox)
              kind = :char
            elsif scan(/ \\ | $ /x)
              tokens << [:close, :string]
              kind = :error
              state = :initial
            else
              raise_inspect "else case \" reached; %p not handled." % peek(1), tokens
            end

          else
            raise_inspect 'Unknown state', tokens

          end

          match ||= matched
          if $DEBUG and not kind
            raise_inspect 'Error token %p in line %d' %
              [[match, kind], line], tokens
          end
          raise_inspect 'Empty token', tokens unless match

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
