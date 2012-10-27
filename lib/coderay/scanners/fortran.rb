module CodeRay
module Scanners

  # by Ralf Mueller
  class Fortran < Scanner

    register_for :fortran

    include Streamable

    KEYWORDS = %w[
    allocatable allocate assign assignment backspace
    block call close common
    contains continue cycle data deallocate
    dimension endfile end entry equivalence exit
    external  format  goto
    implicit include inquire intent
     intrinsic  namelist none
    nully only open operator optional parameter
    pause pointer print private procedure
     public read recursive result return
    rewind save  sequence stop
    target use  while write] +
    # F95 keywords.
    %w[elemental pure] +
    # F2003
    %w[abstract associate asynchronous bind class
    deferred enum enumerator extends extends_type_of
    final generic import non_intrinsic non_overridable
    nopass pass protected same_type_as value volatile]

    BLOCKS = %w[
    do if interface function module program then case end else elseif elsewhere
    enddo endif
    select subroutine type where forall] +
    # F2003.
    %w[enum associate]

    OPERATORS = %w[
    and eq eqv false ge gt le lt ne neqv not or true]

    TYPES = %w[
      character complex integer logical real double precision]

    PROCEDURES = %w[
    abs achar acos adjustl adjustr aimag aint
    all allocated anint any asin associated
    atan atan2 bit_size btest ceiling char cmplx
    conjg cos cosh count cshift date_and_time dble
    digits dim dot_product dprod eoshift epsilon
    exp exponent floor fraction huge iachar iand
    ibclr ibits ibset ichar ieor index int ior
    ishft ishftc kind lbound len len_trim lge lgt
    lle llt log log10 matmul max
    maxexponent maxloc maxval merge min minexponent
    minloc minval mod modulo mvbits nearest nint
    not pack precision present product radix] +
    #  Real is taken out here to avoid highlighting declarations.
    %w[ random_number random_seed range
    repeat reshape rrspacing scale scan
    selected_int_kind selected_real_kind set_exponent
    shape sign sin sinh size spacieg spread sqrt
    sum system_clock tan tanh tiny transfer
    transpose trim ubound unpack verify ] +
    #  F95 intrinsic functions.
    %w[null cpu_time] +
    #  F2003.
    %w[ move_alloc command_argument_count get_command
    get_command_argument get_environment_variable
    selected_char_kind wait flush new_line
    extends extends_type_of same_type_as bind ] +
    #  F2003 ieee_arithmetic intrinsic module.
    %w[ ieee_support_underflow_control ieee_get_underflow_mode
    ieee_set_underflow_mode ] +
    #  F2003 iso_c_binding intrinsic module.
    %w[ c_loc c_funloc c_associated c_f_pointer
    c_f_procpointer ] +
    # more intrinsic hpf
    %w[all_prefix all_scatter all_suffix any_prefix
    any_scatter any_suffix copy_prefix copy_scatter
    copy_suffix count_prefix count_scatter count_suffix
    grade_down grade_up
    hpf_alignment hpf_distribution hpf_template iall iall_prefix
    iall_scatter iall_suffix iany iany_prefix iany_scatter
    iany_suffix ilen iparity iparity_prefix
    iparity_scatter iparity_suffix leadz maxval_prefix
    maxval_scatter maxval_suffix minval_prefix minval_scatter
    minval_suffix number_of_processors parity
    parity_prefix parity_scatter parity_suffix popcnt poppar
    processors_shape product_prefix product_scatter
    product_suffix sum_prefix sum_scatter sum_suffix] +
    #  Directives.
    %w[align distribute dynamic independent inherit processors
    realign redistribute template] +
    #  Keywords.
    %w[block cyclic extrinsic new onto pure with]

    CONSTANTS = %w[
    # F2003 iso_fortran_env constants.
    iso_fortran_env
    input_unit output_unit error_unit
    iostat_end iostat_eor
    numeric_storage_size character_storage_size
    file_storage_size] +
    # F2003 iso_c_binding constants.
    %w[iso_c_binding
    c_int c_short c_long c_long_long c_signed_char
    c_size_t
    c_int8_t c_int16_t c_int32_t c_int64_t
    c_int_least8_t c_int_least16_t c_int_least32_t
    c_int_least64_t
    c_int_fast8_t c_int_fast16_t c_int_fast32_t
    c_int_fast64_t
    c_intmax_t c_intptr_t
    c_float c_double c_long_double
    c_float_complex c_double_complex c_long_double_complex
    c_bool c_char
    c_null_char c_alert c_backspace c_form_feed
    c_new_line c_carriage_return c_horizontal_tab
    c_vertical_tab
    c_ptr c_funptr c_null_ptr c_null_funptr
    ieee_exceptions
    ieee_arithmetic
    ieee_features]

    IDENT_KIND = CaseIgnoringWordList.new(:ident).
      add(KEYWORDS  ,:reserved).
      add(BLOCKS    ,:class).
      add(OPERATORS ,:operator_fat).
      add(PROCEDURES,:function).
      add(TYPES     ,:pre_type).
      add(CONSTANTS ,:pre_constant)

    ESCAPE = / [rbfnrtv\n\\'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} /x
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

          elsif scan(%r@ \! [^\n\\]* (?: \\. [^\n\\]* )* @imx)
            kind = :comment

          elsif match = scan(/ \# \s* if \s* 0 /x)
            match << scan_until(/ ^\# (?:elif|else|endif) .*? $ | \z /xm) unless eos?
            kind = :comment

          elsif scan(/ [-+*\/=<>?:;,!&^|()\[\]{}~%]+ | \.(?!\d) /x)
            kind = :operator_fat

          elsif match = scan(/ [A-Za-z_][A-Za-z_0-9]* /x)
            kind = IDENT_KIND[match]
            if kind == :ident and check(/:(?!:)/)
              match << scan(/:/)
              kind = :label
            end

          elsif match = scan(/L?["']/)
            tokens << [:open, :string]
            if match[0] == ?L
              tokens << ['L', :modifier]
              match = '"'
            end
            state = :string
            kind = :delimiter

          elsif scan(/#\s*(\w*)/)
            kind = :preprocessor  # FIXME multiline preprocs
            state = :include_expected if self[1] == 'include'

          elsif scan(/0[xX][0-9A-Fa-f]+/)
            kind = :hex

          elsif scan(/(?:0[0-7]+)(?![89.eEfF])/)
            kind = :oct

          elsif scan(/[-+]?((\d+\.\d*|\.\d+)([ED][-+]?\d+(?!_)|(E[-+]?\d+)?_\w+)?|\d+([ED][-+]?\d+(?!_)|(E[-+]?\d+)?_\w+))/i)
            kind = :float

          elsif scan(/(?:\d+)(?![.eEfF])/)
            kind = :integer

          else
            getch
            kind = :error

          end

        when :string
          if scan(/[^\\\n"']+/)
            kind = :content
          elsif  md = scan(/["']/)
            tokens << [md, :delimiter]
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

        when :include_expected
          if scan(/[^\n]+/)
            kind = :include
            state = :initial

          elsif match = scan(/\s+/)
            kind = :space
            state = :initial if match.index ?\n

          else
            getch
            kind = :error

          end

        else
          raise_inspect 'Unknown state', tokens

        end

        match ||= matched
        if $CODERAY_DEBUG and not kind
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