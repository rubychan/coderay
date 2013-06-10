# Scanner for Bash
# Author: Petr Kovar <pejuko@gmail.com>

module CodeRay module Scanners

  class Bash < Scanner

    register_for :bash
    file_extension 'sh'
    title 'bash script'

    RESERVED_WORDS = %w(
      ! [[ ]] case do done elif else esac fi for function if in select then time until while { }
    )

    COMMANDS = %w(
      : . break cd continue eval exec exit export getopts hash pwd
      readonly return shift test [ ] times trap umask unset
    )

    BASH_COMMANDS = %w(
      alias bind builtin caller command declare echo enable help let
      local logout printf read set shopt source type typeset ulimit unalias
    )

    PROGRAMS = %w(
      awk bash bunzip2 bzcat bzip2 cat chgrp chmod chown cp cut date dd df dir dmesg du ed egrep
      false fgrep findmnt fusermount gawk grep groups gunzip gzip hostname install keyctl kill less
      ln loadkeys login ls lsblk lsinitcpio lsmod mbchk mkdir mkfifo mknod more mount mountpoint mv
      netstat pidof ping ping6 ps pwd readlink red rm rmdir sed sh shred sleep stty su sudo sync tar
      touch  tput tr traceroute traceroute6 true umount uname uncompress vdir zcat
    )

    VARIABLES = %w(
      CDPATH HOME IFS MAIL MAILPATH OPTARG OPTIND PATH PS1 PS2
    )

    BASH_VARIABLES = %w(
      BASH BASH_ARGC BASH_ARGV BASH_COMMAND BASH_ENV BASH_EXECUTION_STRING
      BASH_LINENO BASH_REMATCH BASH_SOURCE BASH_SUBSHELL BASH_VERSINFO
      BASH_VERSINFO[0] BASH_VERSINFO[1] BASH_VERSINFO[2] BASH_VERSINFO[3] 
      BASH_VERSINFO[4] BASH_VERSINFO[5] BASH_VERSION COLUMNS COMP_CWORD
      COMP_LINE COMP_POINT COMP_WORDBREAKS COMP_WORDS COMPREPLAY DIRSTACK
      EMACS EUID FCEDIT FIGNORE FUNCNAME GLOBIGNORE GROUPS histchars HISTCMD
      HISTCONTROL HISTFILE HISTFILESIZE HISTIGNORE HISTSIZE HISTTIMEFORMAT
      HOSTFILE HOSTNAME HOSTTYPE IGNOREEOF INPUTRC LANG LC_ALL LC_COLLATE
      LC_CTYPE LC_MESSAGE LC_NUMERIC LINENNO LINES MACHTYPE MAILCHECK OLDPWD
      OPTERR OSTYPE PIPESTATUS POSIXLY_CORRECT PPID PROMPT_COMMAND PS3 PS4 PWD
      RANDOM REPLAY SECONDS SHELL SHELLOPTS SHLVL TIMEFORMAT TMOUT TMPDIR UID
    )

    PRE_CONSTANTS = / \$\{? (?: \# | \? | \d | \* | @ | - | \$ | \! | _ ) \}? /ox

    IDENT_KIND = WordList.new(:ident).
      add(RESERVED_WORDS, :reserved).
      add(COMMANDS, :method).
      add(BASH_COMMANDS, :method).
#      add(PROGRAMS, :method).
      add(VARIABLES, :predefined).
      add(BASH_VARIABLES, :predefined)

    attr_reader :state, :quote

    def initialize(*args)
      super(*args)
      @state = :initial
      @quote = nil
      @shell = false
      @brace_shell = 0
      @quote_brace_shell = 0
    end

    def scan_tokens encoder, options

      until eos?
        kind = match = nil

        if match = scan(/\n/)
          encoder.text_token(match, :end_line)
          next
        end

        if @state == :initial
          if  match = scan(/\A#!.*/)
            kind = :directive
          elsif match = scan(/\s*#.*/)
            kind = :comment
          elsif match = scan(/[^"]#/)
            kind = :ident
          elsif match = scan(/\.\.+/)
            kind = :plain
          elsif match = scan(/(?:\.|source)\s+/)
            kind = :reserved
          elsif match = scan(/(?:\\.|,)/)
            kind = :plain
          elsif match = scan(/;/)
            kind = :delimiter
          elsif match = scan(/"/)
            @state = :quote
            @quote = match
            encoder.begin_group :string
            encoder.text_token(match, :delimiter)
            next
          elsif match = scan(/<<\S+/)
            @state = :quote
            match =~ /<<(\S+)/
            @quote = "#{$1}"
            encoder.begin_group :string
            encoder.text_token(match, :delimiter)
            next
          elsif match = scan(/`/)
            if @shell
              encoder.text_token(match, :delimiter)
              encoder.end_group :shell
            else
              encoder.begin_group :shell
              encoder.text_token(match, :delimiter)
            end
            @shell = (not @shell)
            next
          elsif match = scan(/'[^']*'?/)
            kind = :string
          elsif match = scan(/(?: \& | > | < | \| >> | << | >\& )/ox)
            kind = :bin
          elsif match = scan(/\d+[\.-](?:\d+[\.-]?)+/)
            #versions, dates, and hyphen delimited numbers
            kind = :float
          elsif match = scan(/\d+\.\d+\s+/)
            kind = :float
          elsif match = scan(/\d+/)
            kind = :integer
          elsif match = scan(/ (?: \$\(\( | \)\) ) /x)
            kind = :global_variable
          elsif match = scan(/ \$\{ [^\}]+ \} /ox)
            match =~ /\$\{(.*)\}/
            var=$1
            if var =~ /\[.*\]/
              encoder.text_token("${", :instance_variable)
              match_array(var, encoder)
              encoder.text_token("}", :instance_variable)
              next
            end
            kind = IDENT_KIND[var]
            kind = :instance_variable if kind == :ident
          #elsif match = scan(/ \$\( [^\)]+ \) /ox)
          elsif match = scan(/ \$\( /ox)
            @brace_shell += 1
            encoder.begin_group :shell
            encoder.text_token(match, :delimiter)
            next
          elsif @brace_shell > 0 && match = scan(/ \) /ox)
            encoder.text_token(match, :delimiter)
            encoder.end_group :shell
            @brace_shell -= 1
            next
          elsif match = scan(PRE_CONSTANTS)
            kind = :predefined_constant
          elsif match = scan(/[^\s'"]*[A-Za-z_][A-Za-z_0-9]*\+?=/)
            match =~ /(.*?)([A-Za-z_][A-Za-z_0-9]*)(\+?=)/
            str = $1
            pre = $2
            op = $3
            kind = :plain
            if str.to_s.strip.empty?
              kind = IDENT_KIND[pre]
              kind = :instance_variable if kind == :ident
              encoder.text_token(pre, kind)
              encoder.text_token(op, :operator)
              next
            end
          elsif match = scan(/[A-Za-z_]+\[[A-Za-z_\@\*\d]+\]/)
            # array
            match_array(match, encoder)
            next
          elsif match = scan(/ \$[A-Za-z_][A-Za-z_0-9]* /ox)
            match =~ /\$(.*)/
            kind = IDENT_KIND[$1]
            kind = :instance_variable if kind == :ident
          elsif match = scan(/read \S+/)
            match =~ /read(\s+)(\S+)/
            encoder.text_token('read', :method)
            encoder.text_token($1, :space)
            encoder.text_token($2, :instance_variable)
            next
          elsif match = scan(/[\!\:\[\]\{\}]/)
            kind = :reserved
          elsif match = scan(/ [A-Za-z_][A-Za-z_\d]*;? /x)
            match =~ /([^;]+);?/
            kind = IDENT_KIND[$1]
            if match[/([^;]+);$/]
              encoder.text_token($1, kind)
              encoder.text_token(';', :delimiter)
              next
            end
          elsif match = scan(/(?: = | - | \+ | \{ | \} | \( | \) | && | \|\| | ;; | ! )/ox)
            kind = :operator
          elsif match = scan(/\s+/)
            kind = :space
          elsif match = scan(/[^ \$"'`\d]/)
            kind = :plain
          elsif match = scan(/.+/)
            # this shouldn't be :reserved for highlighting bad matches
            match, kind = handle_error(match, options)
          end
        elsif @state == :quote
          if (match = scan(/\\.?/))
            kind = :content
          elsif match = scan(/#{@quote}/)
            encoder.text_token(match, :delimiter)
            encoder.end_group :string
            @quote = nil
            @state = :initial
            next
            #kind = :symbol
          elsif match = scan(PRE_CONSTANTS)
            kind = :predefined_constant
          elsif match = scan(/ (?: \$\(\(.*?\)\) ) /x)
            kind = :global_variable
          elsif match = scan(/ \$\( /ox)
            encoder.begin_group :shell
            encoder.text_token(match, :delimiter)
            @quote_brace_shell += 1
            next
          elsif match = scan(/\)/)
            if @quote_brace_shell > 0
              encoder.text_token(match, :delimiter)
              encoder.end_group :shell
              @quote_brace_shell -= 1
              next
            else
              kind = :content
            end
          elsif match = scan(/ \$ (?: (?: \{ [^\}]* \}) | (?: [A-Za-z_0-9]+ ) ) /x)
            match =~ /(\$\{?)([^\}]*)(\}?)/
            pre=$1
            var=$2
            post=$3
            if var =~ /\[.*?\]/
              encoder.text_token(pre,:instance_variable)
              match_array(var, encoder)
              encoder.text_token(post,:instance_variable)
              next
            end
            kind = IDENT_KIND[match]
            kind = :instance_variable if kind == :ident
          elsif match = scan(/[^\)\$#{@quote}\\]+/)
            kind = :content
          else match = scan(/.+/)
            # this shouldn't be
            #kind = :reserved
            #raise match 
            match, kind = handle_error(match, options)
          end
        end
  
        match ||= matched
        encoder.text_token(match, kind)
      end

      if @state == :quote
        encoder.end_group :string 
      end

      encoder
    end
  

    def match_array(match, encoder)
        match =~ /(.+)\[(.*?)\]/
        var = $1
        key = $2
        kind = IDENT_KIND[var]
        kind = :instance_variable if kind == :ident
        encoder.text_token(var, kind)
        encoder.text_token("[", :operator)
        encoder.text_token(key, :key)
        encoder.text_token("]", :operator)
    end
  
    def handle_error(match, options)
      o = {:ignore_errors => true}.merge(options)
      if o[:ignore_errors]
        [match, :plain]
      else
        [">>>>>#{match}<<<<<", :error]        
      end
    end

  end
end
end
