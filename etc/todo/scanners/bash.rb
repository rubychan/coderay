# author: Vincent Landgraf <setcool@gmx.de>
# licence: GPLv2.1
require "rubygems"
require "coderay"

module CodeRay
  module Scanners
    class Bash < Scanner
      include CodeRay::Streamable
      register_for :bash
  
      KEYWORDS = Regexp.new("(%s)(?![a-zA-Z0-9_\-])" % %w{
        if fi until while done for do case in esac select 
        break else then shift function
      }.sort.join('|'))
    
      BUILTIN =  Regexp.new("(%s)(?![a-zA-Z0-9_\-])" % %w{
        cd continue eval exec true false suspend unalias
        exit export getopts hash pwd readonly return test
        times trap umask unset alias bind builtin caller
        command declare echo enable help let local logout
        printf read shopt source type typeset ulimit
        set dirs popd pushd bg fg jobs kill wait disown
      }.sort.join('|'))
  
      GLOBAL_VARIABLES = Regexp.new("(%s)(?![a-zA-Z0-9_\-])" % %w{
        CDPATH HOME IFS MAIL MAILPATH OPTARG LINENO LINES
        OPTIND PATH PS1 PS2 BASH BASH_ARGCBASH_ARGV 
        BASH_COMMAND BASH_ENV BASH_EXECUTION_STRING
        BASH_LINENO BASH_REMATCH BASH_SOURCE COLUMNS
        BASH_SUBSHELL BASH_VERSINFO BASH_VERSION OSTYPE
        COMP_CWORD COMP_LINE COMP_POINT COMP_WORDBREAKS
        COMP_WORDS COMPREPLY DIRSTACK EMACS EUID OTPERR
        FCEDIT FIGNORE FUNCNAME GLOBIGNORE GROUPS OLDPWD
        histchars HISTCMD HISTCONTROL HISTFILE MACHTYPE
        HISTFILESIZE HISTIGNORE HISTSIZE HISTTIMEFOMAT
        HOSTFILE HOSTNAME HOSTTYPE IGNOREEOF INPUTRC LANG
        LC_ALL LC_COLLATE LC_CTYPE LC_MESSAGES LC_NUMERIC
        PIPESTATUS POSIXLY_CORRECT MAILCHECK PPID PS3 PS4
        PROMPT_COMMAND PWD RANDOM REPLY SECONDS SHELL
        SHELLOPTS SHLVL TIMEFORMAT TMOUT TMPDIR UID
      }.sort.join('|'))
  
      VARIABLE_SIMPLE = /\$[a-zA-Z]\w*/
  
      VARIABLE_EXPRESSION = /\$\{[!#]?[a-zA-Z].*?\}/
  
      CONSTANT = /\$[@#?\-$!_0-9]/
  
      def scan_tokens (tokens, options)
        state = :initial
        str_delimiter = nil
    
        until eos?
          if state == :initial
            if match = scan(CONSTANT)
              tokens << [match, :constant]
            elsif match = scan(/(#{VARIABLE_SIMPLE}|#{VARIABLE_EXPRESSION})/)
              tokens << [match, :instance_variable]
            elsif match = scan(/\s+/)
              tokens << [match, :space]
            elsif match = scan(/-[a-zA-Z]\w*(=\w*)?/)
              tokens << [match, :argument]
            elsif match = scan(/[;<>~]|[&]{1,2}|[|]{1,2}|\*/)
              tokens << [match, :operator]
            elsif match = scan(/[1-9][0-9]*/)
              tokens << [match, :number]
            elsif ((!tokens.empty? and tokens.last[1] != :escape) or tokens.empty? ) and 
              (str_delimiter = scan(/["'`]/))
              # don't match if last token is backsplash
              tokens << [:open, :string]
              tokens << [str_delimiter, :delimiter]
              state = :string
            elsif match = scan(/\\/)
              tokens << [match, :escape]
            elsif match = scan(KEYWORDS)
              tokens << [match, :reserved]
            elsif match = scan(BUILTIN)
              tokens << [match, :method]
            elsif match = scan(GLOBAL_VARIABLES)
              tokens << [match, :global_variable]
            elsif match = scan(/[a-zA-Z]\w*/)
              tokens << [match, :ident]
            elsif match = scan(/\#!.*/) # until eof
              tokens << [match, :doctype]
            elsif match = scan(/\#.*/) # until eof  
              tokens << [match, :comment]
            # catch the rest as other
            else c = getch
              tokens << [c, :other]
            end
          elsif state == :string
            if match = scan(/[\\][abefnrtv\\#{str_delimiter}]/)
              tokens << [match, :escape]
            elsif match = scan(CONSTANT)
              tokens << [:open, :inline]
              tokens << [match, :constant]
              tokens << [:close, :inline]
            elsif match = scan(/(#{VARIABLE_SIMPLE}|#{VARIABLE_EXPRESSION})/)
              tokens << [:open, :inline]
              tokens << [match, :instance_variable]
              tokens << [:close, :inline]
            elsif match = scan(/[^\n#{str_delimiter}\\][^\n#{str_delimiter}$\\]*/)
              tokens << [match, :content]
            elsif match = scan(Regexp.new(str_delimiter))
              tokens << [match, :delimiter]
              tokens << [:close, :string]
              state = :initial
            elsif scan(/\n/)
              tokens << [:close, :string]
              state = :initial
            else
              raise 'String: else-case reached', tokens
            end
          else
            raise 'else-case reached', tokens
          end
        end
    
        return tokens
      end
    end
  end
end