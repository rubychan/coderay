module CodeRay module Scanners
  
  class BASH < Scanner

    register_for :bash
    
    RESERVED_WORDS = %w{
      if elif fi until while done for do case in esac select 
      break else then shift function
    }

    PREDEFINED_CONSTANTS = %w{
        $CDPATH $HOME $IFS $MAIL $MAILPATH $OPTARG $LINENO $LINES
        $OPTIND $PATH $PS1 $PS2 $BASH $BASH_ARGCBASH_ARGV
        $BASH_COMMAND $BASH_ENV $BASH_EXECUTION_STRING
        $BASH_LINENO $BASH_REMATCH $BASH_SOURCE $COLUMNS
        $BASH_SUBSHELL $BASH_VERSINFO $BASH_VERSION $OSTYPE
        $COMP_CWORD $COMP_LINE $COMP_POINT $COMP_WORDBREAKS
        $COMP_WORDS $COMPREPLY $DIRSTACK $EMACS $EUID $OTPERR
        $FCEDIT $FIGNORE $FUNCNAME $GLOBIGNORE $GROUPS $OLDPWD
        $histchars $HISTCMD $HISTCONTROL $HISTFILE $MACHTYPE
        $HISTFILESIZE $HISTIGNORE $HISTSIZE $HISTTIMEFOMAT
        $HOSTFILE $HOSTNAME $HOSTTYPE $IGNOREEOF $INPUTRC $LANG
        $LC_ALL $LC_COLLATE $LC_CTYPE $LC_MESSAGES $LC_NUMERIC
        $PIPESTATUS $POSIXLY_CORRECT $MAILCHECK $PPID $PS3 $PS4
        $PROMPT_COMMAND $PWD $RANDOM $REPLY $SECONDS $SHELL
        $SHELLOPTS $SHLVL $TIMEFORMAT $TMOUT $TMPDIR $UID
    }

    BUILTIN =  %w{
      cd continue eval exec true false suspend unalias
      exit export getopts hash pwd readonly return test
      times trap umask unset alias bind builtin caller
      command declare echo enable help let local logout
      printf read shopt source type typeset ulimit
      set dirs popd pushd bg fg jobs kill wait disown
    }

    IDENT_KIND = WordList.new(:ident).
      add(RESERVED_WORDS, :reserved).
      # add(PREDEFINED_CONSTANTS, :pre_constant).
      add(BUILTIN, :method)

    ESCAPE = / [\$rtnb\n\\'"] /x
    # UNICODE_ESCAPE =  / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x

    VARIABLE_SIMPLE = /\$[a-zA-Z]\w*/
    VARIABLE_EXPRESSION = /\$\{[!#]?[a-zA-Z].*?\}/

    def scan_tokens tokens, options

      state = :initial
      string_type = nil

      until eos?

        kind = nil
        match = nil

        if state == :initial
          if scan(/ \s+ | \\\n /x)
            kind = :space
          elsif match = scan(/\#!.*/) # until eof
            kind = :preprocessor
          elsif scan(/\#.*/)
            kind = :comment
          elsif scan(/ [-+*\/=<>?:;,!&^|()\[\]{}~%] | \.(?!\d) /x)
            kind = :operator
          elsif match = scan(/[1-9][0-9]*/)
            kind = :number
          elsif scan(/ \\ (?: \S ) /mox)
            kind = :char
          elsif scan(/(#{VARIABLE_SIMPLE}|#{VARIABLE_EXPRESSION})/)
            kind = :instance_variable
          elsif match = scan(/ [$@A-Za-z_][A-Za-z_0-9]* /x)
            kind = IDENT_KIND[match]
          elsif match = scan(/["']/)
            tokens << [:open, :string]
            string_type = matched
            state = :string
            kind = :delimiter
          else
            getch
          end
        elsif state == :regex
          if scan(/[^\\\/]+/)
            kind = :content
          elsif scan(/\\\/|\\/)
            kind = :content
          elsif scan(/\//)
            tokens << [matched, :delimiter]
            tokens << [:close, :regexp]
            state = :initial
            next
          else
            getch
            kind = :content
          end
          
        elsif state == :string
          if scan(/[^\\"']+/)
            kind = :content
          elsif scan(/["']/)
            if string_type==matched
              tokens << [matched, :delimiter]
              tokens << [:close, :string]
              state = :initial
              string_type=nil
              next
            else
              kind = :content
            end
          elsif scan(/ \\ (?: \S ) /mox)
            kind = :char
          elsif scan(/ \\ | $ /x)
            # kind = :error
            kind = :content
            state = :initial
          else
            raise "else case \" reached; %p not handled." % peek(1), tokens
          end
        else
          raise 'else-case reached', tokens
        end
        match ||= matched
        tokens << [match, kind]
      end
      tokens
    end
  end
end end
