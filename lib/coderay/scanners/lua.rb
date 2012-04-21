# -*- coding: utf-8 -*-

# http://www.lua.org/manual/5.2/manual.html
class CodeRay::Scanners::Lua < CodeRay::Scanners::Scanner

  register_for :lua
  file_extension "lua"
  title "Lua"

  KEYWORDS = %w[and break do else elseif end
  for function goto if in
  local not or repeat return
  then until while
  ]

  PREDEFINED_CONSTANTS = %w[false true nil]

  IDENT_KIND = CodeRay::WordList.new(:ident)
    .add(KEYWORDS, :keyword)
    .add(PREDEFINED_CONSTANTS, :predefined_constant)

  protected

  def setup
    @state = :initial
  end

  def scan_tokens(encoder, options)
    @encoder = encoder
    @options = options

    send(:"handle_state_#@state") until eos?


    @encoder
  end

  def handle_state_initial
    if match = scan(/\-\-\[\=*\[/)   #--[[ long (possibly multiline) comment ]]
      @num_equals = match.count("=") # Number must match for comment end
      @encoder.begin_group(:comment)
      @encoder.text_token(match, :delimiter)
      @state = :long_comment
    elsif match = scan(/--.*?$/) # --Lua comment
      @encoder.text_token(match, :comment)
    elsif match = scan(/\[=*\[/)     # [[ long (possibly multiline) string ]]
      @num_equals = match.count("=") # Number must match for comment end
      @encoder.begin_group(:string)
      @encoder.text_token(match, :delimiter)
      @state = :long_string
    elsif match = scan(/[a-zA-Z_][a-zA-Z0-9_]*/) # Normal letters (or letters followed by digits)
      kind = IDENT_KIND[match]

      if kind == :keyword and match == "function"
        @state = :function_expected
      end

      @encoder.text_token(match, kind)
    elsif match = scan(/["']/)
      @encoder.begin_group(:string)
      @encoder.text_token(match, :delimiter)
      @start_delim = match
      @state = :string                 # hex number ←|→ decimal number
    elsif match = scan(/0x\h* \. \h+ (?:p[+\-]?\d+)? | \d*\.\d+ (?:e[+\-]?\d+)?/ix) # hexadecimal constants have no E power, decimal ones no P power
      @encoder.text_token(match, :float) #hex | decimal
    elsif match = scan(/0x\h+ (?:p[+\-]?\d+)? | \d+ (?:e[+\-]?\d+)?/ix) # hexadecimal constants have no E power, decimal ones no P power
      @encoder.text_token(match, :integer)
    elsif match = scan(/[\+\-\*\/%^\#=~<>\(\)\{\}\[\]:;,] | \.(?!\d)/x)
      @encoder.text_token(match, :operator)
    elsif match = scan(/\s+/)
      @encoder.text_token(match, :space)
    else
      @encoder.text_token(getch, :error)
    end
  end

  def handle_state_function_expected
    if match = scan(/[a-zA-Z_] (?:[a-zA-Z0-9_\.] (?!\.\d))* \./x) # function tbl.subtbl.foo()
      @encoder.text_token(match, :ident)
    elsif match = scan(/[a-zA-Z_][a-zA-Z0-9_]*/) # function foo()
      @encoder.text_token(match, :function)
      @state = :initial
    elsif match = scan(/\s+/) # Between the function keyword and the ident may be any amount of whitespace
      @encoder.text_token(match, :space)
    else
      @encoder.text_token(getch, :error)
      @state = :initial
    end
  end

  def handle_state_long_comment
    if match = scan(/.*?(?=\]={#@num_equals}\])/m)
      @encoder.text_token(match, :content)

      delim = scan(/\]={#@num_equals}\]/)
      @encoder.text_token(delim, :delimiter)
    else # No terminator found till EOF
      @encoder.text_token(rest, :error)
      terminate
    end
    @encoder.end_group(:comment)
    @state = :initial
  end

  def handle_state_long_string
    if match = scan(/.*?(?=\]={#@num_equals}\])/m) # Long strings do not interpret any escape sequences
      @encoder.text_token(match, :content)

      delim = scan(/\]={#@num_equals}\]/)
      @encoder.text_token(delim, :delimiter)
    else # No terminator found till EOF
      @encoder.text_token(rest, :error)
      terminate
    end
    @encoder.end_group(:string)
    @state = :initial
  end

  def handle_state_string
    if match = scan(/[^\\#@start_delim\n]+/) # Everything except \ and the start delimiter character is string content (newlines are only allowed if preceeded by \ or \z)
      @encoder.text_token(match, :content)
    elsif match = scan(/\\(?:['"abfnrtv\\]|z\s*|x\h\h|\d{1,3}|\n)/m)
      @encoder.text_token(match, :char)
    elsif match = scan(Regexp.compile(@start_delim))
      @encoder.text_token(match, :delimiter)
      @encoder.end_group(:string)
      @state = :initial
    elsif match = scan(/\n/) # Lua forbids unescaped newlines in normal non-long strings
      @encoder.text_token("\\n\n", :error) # Visually appealing error indicator--otherwise users may wonder whether the highlighter cannot highlight multine strings
      @encoder.end_group(:string)
      @state = :initial
    else
      @encoder.text_token(getch, :error)
    end
  end

end
