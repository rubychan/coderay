module CodeRay
module Scanners

  # Scanner for Octave
  class Octave < Scanner

    register_for :octave
    file_extension 'm'

    KEYWORDS = %w[
      __FILE__ __LINE__ break case catch classdef continue do else
      elseif end end_try_catch end_unwind_protect endclassdef
      endevents endfor endfunction endif endmethods endproperties
      endswitch endwhile events for function get global if methods
      otherwise persistent properties return set static switch try
      until unwind_protect unwind_protect_cleanup while
    ]  # :nodoc:

    MAPPING_FUNCTIONS = %w[
      abs acos acosh acot acoth
      acsc acsch angle arg asec
      asech asin asinh atan atan2
      atanh beta betainc betaln bincoeff
      cbrt ceil conj cos cosh
      cot coth csc csch erf
      erfc erfcx erfinv exp expm1
      finite fix floor fmod gamma
      gammainc gammaln imag isalnum isalpha
      isascii iscntrl isdigit isfinite isgraph
      isinf islower isna isnan isprint
      ispunct isspace isupper isxdigit lcm
      lgamma log log10 log1p log2
      lower mod pow2 real rem
      round roundb sec sech sign
      sin sinh sqrt tan tanh
      toascii tolower toupper upper xor
    ]  # :nodoc

    BUILTIN_KEYWORDS = %w[
      addlistener addpath addproperty all
      and any argnames argv assignin
      atexit autoload
      available_graphics_toolkits beep_on_error
      bitand bitmax bitor bitshift bitxor
      cat cell cellstr char class clc
      columns command_line_path
      completion_append_char completion_matches
      complex confirm_recursive_rmdir cputime
      crash_dumps_octave_core ctranspose cumprod
      cumsum debug_on_error debug_on_interrupt
      debug_on_warning default_save_options
      dellistener diag diff disp
      doc_cache_file do_string_escapes double
      drawnow e echo_executing_commands eps
      eq errno errno_list error eval
      evalin exec exist exit eye false
      fclear fclose fcntl fdisp feof
      ferror feval fflush fgetl fgets
      fieldnames file_in_loadpath file_in_path
      filemarker filesep find_dir_in_path
      fixed_point_format fnmatch fopen fork
      formula fprintf fputs fread freport
      frewind fscanf fseek fskipl ftell
      functions fwrite ge genpath get
      getegid getenv geteuid getgid
      getpgrp getpid getppid getuid glob
      gt gui_mode history_control
      history_file history_size
      history_timestamp_format_string home
      horzcat hypot ifelse
      ignore_function_time_stamp inferiorto
      info_file info_program inline input
      intmax intmin ipermute
      is_absolute_filename isargout isbool
      iscell iscellstr ischar iscomplex
      isempty isfield isfloat isglobal
      ishandle isieee isindex isinteger
      islogical ismatrix ismethod isnull
      isnumeric isobject isreal
      is_rooted_relative_filename issorted
      isstruct isvarname kbhit keyboard
      kill lasterr lasterror lastwarn
      ldivide le length link linspace
      logical lstat lt make_absolute_filename
      makeinfo_program max_recursion_depth merge
      methods mfilename minus mislocked
      mkdir mkfifo mkstemp mldivide mlock
      mouse_wheel_zoom mpower mrdivide mtimes
      munlock nargin nargout
      native_float_format ndims ne nfields
      nnz norm not numel nzmax
      octave_config_info octave_core_file_limit
      octave_core_file_name
      octave_core_file_options ones or
      output_max_field_width output_precision
      page_output_immediately page_screen_output
      path pathsep pause pclose permute
      pi pipe plus popen power
      print_empty_dimensions printf
      print_struct_array_contents prod
      program_invocation_name program_name
      putenv puts pwd quit rats rdivide
      readdir readlink read_readline_init_file
      realmax realmin rehash rename
      repelems re_read_readline_init_file reset
      reshape resize restoredefaultpath
      rethrow rmdir rmfield rmpath rows
      save_header_format_string save_precision
      saving_history scanf set setenv
      shell_cmd sighup_dumps_octave_core
      sigterm_dumps_octave_core silent_functions
      single size size_equal sizemax
      sizeof sleep source sparse_auto_mutate
      split_long_rows sprintf squeeze sscanf
      stat stderr stdin stdout strcmp
      strcmpi string_fill_char strncmp
      strncmpi struct struct_levels_to_print
      strvcat subsasgn subsref sum sumsq
      superiorto suppress_verbose_help_message
      symlink system tic tilde_expand
      times tmpfile tmpnam toc toupper
      transpose true typeinfo umask uminus
      uname undo_string_escapes unlink uplus
      upper usage usleep vec vectorize
      vertcat waitpid warning warranty
      whos_line_format yes_or_no zeros
      inf Inf nan NaN
    ]  # :nodoc:

    LOADABLE_FUNCTIONS = %w[
      airy amd balance besselh besseli
      besselj besselk bessely bitpack bitunpack
      blkmm bsxfun builtin ccolamd cellfun
      cellindexmat cellslices chol chol2inv choldelete
      cholinsert cholinv cholshift cholupdate colamd
      colloc conv2 convhulln convn csymamd
      cummax cummin daspk daspk_options dasrt
      dasrt_options dassl dassl_options dbclear dbdown
      dbstack dbstatus dbstop dbtype dbup
      dbwhere det dlmread dmperm dot
      eig eigs endgrent endpwent etree
      fft fft2 fftn fftw filter
      find full gcd getgrent getgrgid
      getgrnam get_help_text get_help_text_from_file getpwent getpwnam
      getpwuid getrusage givens gmtime gnuplot_binary
      hess hex2num ifft ifft2 ifftn
      inv isdebugmode issparse kron localtime
      lookup lsode lsode_options lu luinc
      luupdate mat2cell matrix_type max md5sum
      mgorth min mktime nproc num2cell
      num2hex onCleanup pinv qr qrdelete
      qrinsert qrshift qrupdate quad quad_options
      qz rand rande randg randn
      randp randperm rcond regexp regexpi
      regexprep schur setgrent setpwent sort
      spalloc sparse spparms sprank sqrtm
      strfind strftime strptime strrep svd
      svd_driver syl symamd symbfact symrcm
      time tsearch typecast urlread urlwrite
    ]

    FUNCTIONS = %w[
      accumarray accumdim acosd acotd acscd
      addpref addtodate allchild ancestor anova
      arch_fit arch_rnd arch_test area arma_rnd
      arrayfun ascii asctime asecd asind
      assert atand autoreg_matrix autumn axes
      axis bar barh bartlett bartlett_test
      base2dec beep betacdf betainv betapdf
      betarnd bicg bicgstab bicubic bin2dec
      binary binocdf binoinv binopdf binornd
      bitcmp bitget bitset blackman blanks
      blkdiag bone box brighten bunzip2
      bzip2 calendar cart2pol cart2sph cast
      cauchy_cdf cauchy_inv cauchy_pdf cauchy_rnd caxis
      cell2mat celldisp center cgs chi2cdf
      chi2inv chi2pdf chi2rnd chisquare_test_homogeneity chisquare_test_independence
      chop circshift cla clabel clf
      clock cloglog closereq colon colorbar
      colormap colperm colstyle comet comet3
      common_size commutation_matrix compan compare_versions compass
      computer cond condest contour contour3
      contourc contourf contrast conv convhull
      cool copper copyfile corr cor_test
      cosd cotd cov cplxpair cross
      cscd cstrcat csvread csvwrite ctime
      cumtrapz curl cylinder daspect date
      datenum datestr datetick datevec dblquad
      deal deblank dec2base dec2bin dec2hex
      deconv del2 delaunay delaunay3 delaunayn
      delete demo detrend diffpara diffuse
      dir discrete_cdf discrete_inv discrete_pdf discrete_rnd
      display divergence dlmwrite dos dsearch
      dsearchn dump_prefs duplication_matrix durbinlevinson ellipsoid
      empirical_cdf empirical_inv empirical_pdf empirical_rnd eomday
      errorbar etime etreeplot example expcdf
      expinv expm exppdf exprnd ezcontour
      ezcontourf ezmesh ezmeshc ezplot ezplot3
      ezpolar ezsurf ezsurfc factor factorial
      fail fcdf feather fftconv fftfilt
      fftshift figure fileattrib fileparts fileread
      fill filter2 findall findobj findstr
      finv flag flipdim fliplr flipud
      fminbnd fminunc foo fpdf fplot
      fractdiff freqz freqz_plot frnd fsolve
      f_test_regression ftp fullfile fzero gamcdf
      gaminv gampdf gamrnd gca gcbf
      gcbo gcf gen_doc_cache genvarname geocdf
      geoinv geopdf geornd getappdata getfield
      get_first_help_sentence getpref ginput glpk gls
      gmap40 gmres gplot gradient graphics_toolkit
      gray gray2ind grid griddata griddata3
      griddatan gtext guidata guihandles gunzip
      gzip hadamard hamming hankel hanning
      hex2dec hggroup hidden hilb hist
      histc hold hot hotelling_test hotelling_test_2
      housh hsv hsv2rgb hurst hygecdf
      hygeinv hygepdf hygernd idivide ifftshift
      image imagesc imfinfo imread imshow
      imwrite ind2gray ind2rgb ind2sub index
      info inpolygon inputname int2str interp1
      interp1q interp2 interp3 interpft interpn
      intersect invhilb iqr isa isappdata
      iscolumn isdefinite isdeployed isdir isequal
      isequalwithequalnans isfigure ishermitian ishghandle ishold
      is_leap_year isletter ismac ismember isocolors
      isonormals isosurface ispc ispref isprime
      isprop isrow isscalar issquare isstrprop
      issymmetric isunix is_valid_file_id isvector jet
      kendall kolmogorov_smirnov_cdf kolmogorov_smirnov_test kolmogorov_smirnov_test_2 kruskal_wallis_test
      krylov kurtosis laplace_cdf laplace_inv laplace_pdf
      laplace_rnd legend legendre license lin2mu
      line linkprop list_primes loadaudio loadobj
      logistic_cdf logistic_inv logistic_pdf logistic_rnd logit
      loglog loglogerr logm logncdf logninv
      lognpdf lognrnd logspace lookfor ls_command
      lsqnonneg magic mahalanobis manova mat2str
      matlabroot mcnemar_test mean meansq median
      menu mesh meshc meshgrid meshz
      mexext mget mkoctfile mkpp mode
      moment movefile mpoles mput mu2lin
      namelengthmax nargchk narginchk nargoutchk nbincdf
      nbininv nbinpdf nbinrnd nchoosek ndgrid
      newplot news nextpow2 nonzeros normcdf
      normest norminv normpdf normrnd now
      nthargout nthroot ntsc2rgb null num2str
      ocean ols onenormest optimget optimset
      orderfields orient orth pack pareto
      parseparams pascal patch pathdef pbaspect
      pcg pchip pcolor pcr peaks
      periodogram perl perms pie pie3
      pink planerot playaudio plot plot3
      plotmatrix plotyy poisscdf poissinv poisspdf
      poissrnd pol2cart polar poly polyaffine
      polyarea polyder polyfit polygcd polyint
      polyout polyreduce polyval polyvalm postpad
      powerset ppder ppint ppjumps ppplot
      ppval pqpnonneg prctile prepad primes
      print print_usage prism probit profexplore
      profile profshow prop_test_2 python qp
      qqplot quadcc quadgk quadl quadv
      quantile quiver quiver3 qzhess rainbow
      randi range rank ranks rat
      reallog realpow realsqrt record rectangle
      rectangle_lw rectangle_sw rectint recycle refresh
      refreshdata regexptranslate repmat residue rgb2hsv
      rgb2ind rgb2ntsc ribbon rindex rmappdata
      rmpref roots rose rosser rot90
      rotdim rref rsf2csf run run_count
      rundemos runlength run_test runtests saveas
      saveaudio saveobj savepath scatter scatter3
      secd semilogx semilogxerr semilogy semilogyerr
      setappdata setaudio setdiff setfield setpref
      setxor shading shift shiftdim sign_test
      sinc sind sinetone sinewave skewness
      slice sombrero sortrows spaugment spconvert
      spdiags spearman spectral_adf spectral_xdf specular
      speed spencer speye spfun sph2cart
      sphere spinmap spline spones sprand
      sprandn sprandsym spring spstats spy
      sqp stairs statistics std stdnormal_cdf
      stdnormal_inv stdnormal_pdf stdnormal_rnd stem stem3
      stft str2num strcat strchr strjust
      strmatch strread strsplit strtok strtrim
      strtrunc structfun sub2ind subplot subsindex
      subspace substr substruct summer surf
      surface surfc surfl surfnorm svds
      swapbytes symvar synthesis table tand
      tar tcdf tempdir tempname test
      text textread textscan tinv title
      toeplitz tpdf trace trapz treelayout
      treeplot triangle_lw triangle_sw tril trimesh
      triplequad triplot trisurf triu trnd
      tsearchn t_test t_test_2 t_test_regression type
      uigetdir uigetfile uimenu uiputfile uiresume
      uiwait unidcdf unidinv unidpdf unidrnd
      unifcdf unifinv unifpdf unifrnd union
      unique unix unmkpp unpack untabify
      untar unwrap unzip usejava u_test
      validatestring vander var var_test vech
      ver version view voronoi voronoin
      waitbar waitforbuttonpress wavread wavwrite wblcdf
      wblinv wblpdf wblrnd weekday welch_test
      what white whitebg wienrnd wilcoxon_test
      wilkinson winter xlabel xlim ylabel
      yulewalker zip zlabel zscore z_test
      z_test_2
    ]

    BUILTINS = %w[
      add_input_event_hook addlistener addpath addproperty all
      allow_noninteger_range_as_index and any argnames argv
      assignin atexit autoload available_graphics_toolkits beep_on_error
      bitand bitmax bitor bitshift bitxor
      cat cell cell2struct cellstr char
      class clc columns command_line_path completion_append_char
      completion_matches complex confirm_recursive_rmdir cputime crash_dumps_octave_core
      ctranspose cumprod cumsum debug_on_error debug_on_interrupt
      debug_on_warning default_save_options dellistener diag diff
      disp do_braindead_shortcircuit_evaluation doc_cache_file do_string_escapes double
      drawnow dup2 e echo_executing_commands EDITOR
      eps eq errno errno_list error
      eval evalin exec EXEC_PATH exist
      exit eye false fclear fclose
      fcntl fdisp feof ferror feval
      fflush fgetl fgets fieldnames file_in_loadpath
      file_in_path filemarker filesep find_dir_in_path fixed_point_format
      fnmatch fopen fork formula fprintf
      fputs fread freport frewind fscanf
      fseek fskipl ftell func2str functions
      fwrite ge genpath get getegid
      getenv geteuid getgid gethostname getpgrp
      getpid getppid getuid glob gt
      gui_mode history_control history_file history_size history_timestamp_format_string
      home horzcat hypot I ifelse
      ignore_function_time_stamp IMAGE_PATH Inf inferiorto info_file
      info_program inline input int16 int32
      int64 int8 intmax intmin ipermute
      is_absolute_filename isargout isbool iscell iscellstr
      ischar iscomplex is_dq_string isempty isfield
      isfloat is_function_handle isglobal ishandle isieee
      isindex isinteger iskeyword islogical ismatrix
      ismethod isnull isnumeric isobject isreal
      is_rooted_relative_filename issorted is_sq_string isstruct isvarname
      kbhit keyboard kill lasterr lasterror
      lastwarn ldivide le length link
      linspace list_in_columns loaded_graphics_toolkits logical lstat
      lt make_absolute_filename makeinfo_program max_recursion_depth merge
      methods mfilename minus mislocked missing_function_hook
      mkdir mkfifo mkstemp mldivide mlock
      mouse_wheel_zoom mpower mrdivide mtimes munlock
      NA NaN nargin nargout native_float_format
      ndims ne nfields nnz norm
      not nth_element numel nzmax octave_config_info
      octave_core_file_limit octave_core_file_name octave_core_file_options OCTAVE_HOME OCTAVE_VERSION
      ones optimize_subsasgn_calls or output_max_field_width output_precision
      page_output_immediately PAGER PAGER_FLAGS page_screen_output path
      pathsep pause pclose permute pi
      pipe plus popen popen2 power
      print_empty_dimensions printf print_struct_array_contents prod program_invocation_name
      program_name PS1 PS2 PS4 P_tmpdir
      putenv puts pwd quit rats
      rdivide readdir readlink read_readline_init_file realmax
      realmin register_graphics_toolkit rehash remove_input_event_hook rename
      repelems re_read_readline_init_file reset reshape resize
      restoredefaultpath rethrow rmdir rmfield rmpath
      rows save_header_format_string save_precision saving_history scanf
      SEEK_CUR SEEK_END SEEK_SET set setenv
      SIG sighup_dumps_octave_core sigterm_dumps_octave_core silent_functions single
      S_ISBLK S_ISCHR S_ISDIR S_ISFIFO S_ISLNK
      S_ISREG S_ISSOCK size size_equal sizemax
      sizeof sleep source sparse_auto_mutate split_long_rows
      sprintf squeeze sscanf stat stderr
      stdin stdout str2double str2func strcmp
      strcmpi string_fill_char strncmp strncmpi struct
      struct2cell struct_levels_to_print strvcat subsasgn subsref
      sum sumsq superiorto suppress_verbose_help_message symlink
      system terminal_size tic tilde_expand times
      tmpfile tmpnam toc transpose true
      typeinfo uint16 uint32 uint64 uint8
      umask uminus uname undo_string_escapes unlink
      uplus usage usleep vec vectorize
      vertcat waitfor waitpid warning warranty
      WCONTINUE WCOREDUMP WEXITSTATUS whos_line_format WIFCONTINUED
      WIFEXITED WIFSIGNALED WIFSTOPPED WNOHANG WSTOPSIG
      WTERMSIG WUNTRACED yes_or_no zeros
    ]  # :nodoc

    COMMANDS = %w[
      close load who whos
    ]  # :nodoc

    IDENT_KIND = WordList.new(:ident).
      add(KEYWORDS, :keyword).
      add(MAPPING_FUNCTIONS, :mapping).
      add(FUNCTIONS + LOADABLE_FUNCTIONS, :function).
      add(BUILTIN_KEYWORDS + BUILTINS, :predefined).
      add(COMMANDS, :predefined_constant)  # :nodoc:

    ESCAPE = / [rbfntv\n\\'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} /x  # :nodoc:
    UNICODE_ESCAPE = / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x  # :nodoc:

    OPERATOR = Regexp.union /[<>~!=-]=?/, /==|~=|--|\/=/, /&&?|\|\|?/, /\.\'/, /[\'@,:;(){}\[\]]/  # :nodoc:
    # these operators require escape for regexp
    OPERATOR_ESC = Regexp.union "...", "*=", "+=", "^=", "/=", "\\=", "**", "++", ".**", ".*", "*", "+", ".^", ".\\", "./", ".", "/", "\\", "^"

    SINGLE_QUOTED_STRING = /([,\(]) (\s*) (') ([^']*) (')/x

  protected

    def scan_tokens encoder, options

      state = :initial

      until eos?

        case state

        when :initial

          if match = scan(/ \s+ /x)
            encoder.text_token match, :space

          elsif match = scan(/ \s* [%#] .* $ /x)
            encoder.text_token match, :comment

          # Since the single-quote mark is also used for the transpose operator
          # (see Arithmetic Ops) but double-quote marks have no other purpose in
          # Octave, it is best to use double-quote marks to denote strings.
          #
          #   http://www.gnu.org/software/octave/doc/interpreter/Strings.html

          # two cases hacked:
          #   ( 'content'
          #   , 'content'

          elsif match = scan(SINGLE_QUOTED_STRING)
            match_data = SINGLE_QUOTED_STRING.match match
            encoder.text_token(match_data[1], :operator)
            encoder.text_token(match_data[2], :space) unless match[2].empty?
            encoder.begin_group :string
            encoder.text_token(match_data[3], :delimiter)
            encoder.text_token(match_data[4], :content)
            encoder.text_token(match_data[5], :delimiter)
            encoder.end_group :string

          elsif match = scan(/"/)
            encoder.begin_group :string
            encoder.text_token match, :delimiter
            state = :string

          elsif match = scan(OPERATOR)
            encoder.text_token match, :operator
          elsif match = scan(OPERATOR_ESC)
            encoder.text_token match, :operator

          elsif match = scan(/ [A-Za-z_][A-Za-z_0-9]* /x)
            kind = IDENT_KIND[match]
            if kind == :mapping
              encoder.begin_group :map
              encoder.text_token match, :content
              encoder.end_group :map
            else
              encoder.text_token match, kind
            end

          elsif match = scan(/0[xX][0-9A-Fa-f]+/)
            encoder.text_token match, :hex

          elsif match = scan(/(?:0[0-7]+)(?![89.eEfF])/)
            encoder.text_token match, :octal

          elsif match = scan(/\d*\.\d+(?:[eE][+-]?\d+)?[fF]?|\d+[eE][+-]?\d+[fF]?/)
            encoder.text_token match, :float

          elsif match = scan(/\d+/)
            encoder.text_token match, :float

          else
            encoder.text_token getch, :error

          end

        when :string
          if match = scan(/[^\\\n"]+/)
            encoder.text_token match, :content
          elsif match = scan(/"/)
            encoder.text_token match, :delimiter
            encoder.end_group :string
            state = :initial
          elsif match = scan(/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox)
            encoder.text_token match, :char
          elsif match = scan(/ \\ | $ /x)
            encoder.end_group :string
            encoder.text_token match, :error unless match.empty?
            state = :initial
          else
            raise_inspect "else case \" reached; %p not handled." % peek(1), encoder
          end

        else
          raise_inspect 'Unknown state', encoder

        end

      end

      if state == :string
        encoder.end_group :string
      end

      encoder
    end

  end

end
end
