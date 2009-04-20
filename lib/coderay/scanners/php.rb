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
      
      # according to http://www.php.net/manual/en/reserved.keywords.php
      KEYWORDS = %w[
        abstract and array as break case catch class clone
        const continue declare default do else elseif
        enddeclare endfor endforeach endif endswitch endwhile
        extends final for foreach function global goto if implements
        interface instanceof namespace new or
        private protected public static switch throw try use var
        while xor
        cfunction old_function
        null true false
      ]
      
      LANGUAGE_CONSTRUCTS = %w[
        die echo empty exit eval include include_once isset list
        require require_once return print unset
      ]
      
      TYPES = %w[ int float ]
      
      # according to http://php.net/quickref.php on 2009-04-21;
      # all functions with _ excluded (module functions)
      BUILTIN_FUNCTIONS = %w[
        abs acos acosh addcslashes addslashes aggregate array arsort ascii2ebcdic asin asinh asort assert atan atan2
        atanh basename bcadd bccomp bcdiv bcmod bcmul bcpow bcpowmod bcscale bcsqrt bcsub bin2hex bindec
        bindtextdomain bzclose bzcompress bzdecompress bzerrno bzerror bzerrstr bzflush bzopen bzread bzwrite
        calculhmac ceil chdir checkdate checkdnsrr chgrp chmod chop chown chr chroot clearstatcache closedir closelog
        compact constant copy cos cosh count crc32 crypt current date dcgettext dcngettext deaggregate decbin dechex
        decoct define defined deg2rad delete dgettext die dirname diskfreespace dl dngettext doubleval each
        ebcdic2ascii echo empty end ereg eregi escapeshellarg escapeshellcmd eval exec exit exp explode expm1 extract
        fclose feof fflush fgetc fgetcsv fgets fgetss file fileatime filectime filegroup fileinode filemtime fileowner
        fileperms filepro filesize filetype floatval flock floor flush fmod fnmatch fopen fpassthru fprintf fputcsv
        fputs fread frenchtojd fscanf fseek fsockopen fstat ftell ftok ftruncate fwrite getallheaders getcwd getdate
        getenv gethostbyaddr gethostbyname gethostbynamel getimagesize getlastmod getmxrr getmygid getmyinode getmypid
        getmyuid getopt getprotobyname getprotobynumber getrandmax getrusage getservbyname getservbyport gettext
        gettimeofday gettype glob gmdate gmmktime gmstrftime gregoriantojd gzclose gzcompress gzdecode gzdeflate
        gzencode gzeof gzfile gzgetc gzgets gzgetss gzinflate gzopen gzpassthru gzputs gzread gzrewind gzseek gztell
        gzuncompress gzwrite hash header hebrev hebrevc hexdec htmlentities htmlspecialchars hypot iconv idate
        implode include intval ip2long iptcembed iptcparse isset
        jddayofweek jdmonthname jdtofrench jdtogregorian jdtojewish jdtojulian jdtounix jewishtojd join jpeg2wbmp
        juliantojd key krsort ksort lcfirst lchgrp lchown levenshtein link linkinfo list localeconv localtime log
        log10 log1p long2ip lstat ltrim mail main max md5 metaphone mhash microtime min mkdir mktime msql natcasesort
        natsort next ngettext nl2br nthmac octdec opendir openlog
        ord overload pack passthru pathinfo pclose pfsockopen phpcredits phpinfo phpversion pi png2wbmp popen pos pow
        prev print printf putenv quotemeta rad2deg rand range rawurldecode rawurlencode readdir readfile readgzfile
        readline readlink realpath recode rename require reset rewind rewinddir rmdir round rsort rtrim scandir
        serialize setcookie setlocale setrawcookie settype sha1 shuffle signeurlpaiement sin sinh sizeof sleep snmpget
        snmpgetnext snmprealwalk snmpset snmpwalk snmpwalkoid sort soundex split spliti sprintf sqrt srand sscanf stat
        strcasecmp strchr strcmp strcoll strcspn strftime stripcslashes stripos stripslashes stristr strlen
        strnatcasecmp strnatcmp strncasecmp strncmp strpbrk strpos strptime strrchr strrev strripos strrpos strspn
        strstr strtok strtolower strtotime strtoupper strtr strval substr symlink syslog system tan tanh tempnam
        textdomain time tmpfile touch trim uasort ucfirst ucwords uksort umask uniqid unixtojd unlink unpack
        unserialize unset urldecode urlencode usleep usort vfprintf virtual vprintf vsprintf wordwrap
      ] + %w[
        assert_options base_convert base64_decode base64_encode
        chunk_split class_exists class_implements class_parents
        count_chars debug_backtrace debug_print_backtrace debug_zval_dump
        error_get_last error_log error_reporting extension_loaded
        file_exists file_get_contents file_put_contents load_file
        func_get_arg func_get_args func_num_args function_exists
        get_browser get_called_class get_cfg_var get_class get_class_methods get_class_vars
        get_current_user get_declared_classes get_declared_interfaces get_defined_constants
        get_defined_functions get_defined_vars get_extension_funcs get_headers get_html_translation_table
        get_include_path get_included_files get_loaded_extensions get_magic_quotes_gpc get_magic_quotes_runtime
        get_meta_tags get_object_vars get_parent_class get_required_filesget_resource_type
        gc_collect_cycles gc_disable gc_enable gc_enabled
        halt_compiler headers_list headers_sent highlight_file highlight_string
        html_entity_decode htmlspecialchars_decode
        in_array include_once inclued_get_data
        locale_get_default locale_set_default
        number_format override_function parse_str parse_url
        php_check_syntax php_ini_loaded_file php_ini_scanned_files php_logo_guid php_sapi_name
        php_strip_whitespace php_uname
        preg_filter preg_grep preg_last_error preg_match preg_match_all preg_quote preg_replace
        preg_replace_callback preg_split print_r
        require_once register_shutdown_function register_tick_function
        set_error_handler set_exception_handler set_file_buffer set_include_path
        set_magic_quotes_runtime set_time_limit shell_exec
        str_getcsv str_ireplace str_pad str_repeat str_replace str_rot13 str_shuffle str_split str_word_count
        strip_tags substr_compare substr_count substr_replace
        time_nanosleep time_sleep_until
        token_get_all token_name trigger_error
        unregister_tick_function use_soap_error_handler user_error
        utf8_decode utf8_encode var_dump var_export
        version_compare
        zend_logo_guid zend_thread_id zend_version
      ] + %w[
        array_change_key_case array_chunk array_combine array_count_values array_diff array_diff_assoc
        array_diff_key array_diff_uassoc array_diff_ukey array_fill array_fill_keys array_filter array_flip
        array_intersect array_intersect_assoc array_intersect_key array_intersect_uassoc array_intersect_ukey
        array_key_exists array_keys array_map array_merge array_merge_recursive array_multisort array_pad
        array_pop array_product array_push array_rand array_reduce array_reverse array_search array_shift
        array_slice array_splice array_sum array_udiff array_udiff_assoc array_udiff_uassoc array_uintersect
        array_uintersect_assoc array_uintersect_uassoc array_unique array_unshift array_values array_walk
        array_walk_recursive
      ] + %w[
        is_a is_array is_binary is_bool is_buffer is_callable is_dir is_double is_executable is_file is_finite
        is_float is_infinite is_int is_integer is_link is_long is_nan is_null is_numeric is_object is_readable
        is_real is_resource is_scalar is_soap_fault is_string is_subclass_of is_unicode is_uploaded_file
        is_writable is_writeable
      ]
      
      # TODO: more built-in PHP functions?
      # TODO: more predefined constants?
      
      SPECIAL_CONSTANTS = %w[
        __LINE__ __DIR__ __FILE__ __LINE__
        __CLASS__ __NAMESPACE__ __METHOD__ __FUNCTION__
      ]
      
      IdentKinds = CaseIgnoringWordList.new(:ident, true).
        add(KEYWORDS, :reserved).
        add(TYPES, :pre_type).
        add(LANGUAGE_CONSTRUCTS, :predefined).
        add(BUILTIN_FUNCTIONS, :predefined).
        add(SPECIAL_CONSTANTS, :pre_constant)
    end
    
    module RE
      def self.build_alternatives(array)
        Regexp.new(array.map { |s| Regexp.escape(s) }.join('|') , Regexp::IGNORECASE)
      end
      
      PHP_START = /
        <script\s+[^>]*?language\s*=\s*"php"[^>]*?> |
        <script\s+[^>]*?language\s*=\s*'php'[^>]*?> |
        <\?php\d? |
        <\?(?!xml)
      /xi
      
      PHP_END = %r!
        </script> |
        \?>
      !xi
      
      IChar = /[a-z0-9_\x80-\xFF]/i
      IStart = /[a-z_\x80-\xFF]/i
      Identifier = /#{IStart}#{IChar}*/
      Variable = /\$#{Identifier}/
      
      Typecasts = build_alternatives %w!
        float double real int integer bool boolean string array object null
      !.map{|s| "(#{s})"}
      OneLineComment1 = %r!//.*?(?=#{PHP_END}|$)!
      OneLineComment2 = %r!#.*?(?=#{PHP_END}|$)!
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
      
      Integer = /0x[0-9a-fA-F]/ | /\d+/
      Float = /(?:\d+\.\d*|\d*\.\d+)(?:e[+-]\d+)?/
      
    end
    
    def scan_tokens tokens, options
      states = [:initial]
      if match?(RE::PHP_START) ||  # starts with <?
      (match?(/\s*<(?i:\w|\?xml)/) && exist?(RE::PHP_START))  # starts with HTML tag and contains <?
        # start with HTML
      else
        states << :php
      end
      # heredocdelim = nil
      
      until eos?
        
        match = nil
        kind = nil
        
        case states.last
        
        when :initial  # HTML
          if scan RE::PHP_START
            kind = :inline_delimiter
            states << :php
          else
            match = scan_until(/(?=#{RE::PHP_START})/o) || scan_until(/\z/)
            @html_scanner.tokenize match unless match.empty?
            next
          end
        
        when :php
          if scan RE::PHP_END
            kind = :inline_delimiter
            states.pop
          
          elsif scan(/\s+/)
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
          
          elsif scan RE::Float
            kind = :float
          
          elsif scan RE::Integer
            kind = :integer
          
          elsif scan(/'/)
            tokens << [:open, :string]
            kind = :delimiter
            states.push :sqstring
          
          elsif scan(/"/)
            tokens << [:open, :string]
            kind = :delimiter
            states.push :dqstring
          
          # TODO: Heredocs
          # elsif match = scan(RE::HereDoc)
          #   tokens << [:open, :string]
          #   heredocdelim = match[RE::Identifier]
          #   kind = :delimiter
          #   states.push :heredocstring
          
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
          if scan(/[^'\\]+/)
            kind = :content
          elsif scan(/\\./m)
            kind = :content
          elsif scan(/\\/)
            kind = :error
          elsif scan(/'/)
            tokens << [matched, :delimiter]
            tokens << [:close, :string]
            states.pop
            next
          end
        
        when :dqstring
          # TODO: $foo[bar] kind of stuff
          if scan(/[^"${\\]+/)
            kind = :content
          elsif scan(/\\x[0-9a-fA-F]{2}/)
            kind = :char
          elsif scan(/\\\d{3}/)
            kind = :char
          elsif scan(/\\["\\abcfnrtyv]/)
            kind = :char
          elsif scan(/\\./m)
            kind = :content
          elsif scan(/\\/)
            kind = :error
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
            kind = :content
          elsif scan(/"/)
            tokens << [matched, :delimiter]
            tokens << [:close, :string]
            states.pop
            next
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
