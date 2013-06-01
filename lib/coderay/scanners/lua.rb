# encoding: utf-8

# Scanner for the Lua programming lanuage.
# This scanner attempts to mimic the syntax defined at:
# http://www.lua.org/manual/5.2/manual.html
class CodeRay::Scanners::Lua < CodeRay::Scanners::Scanner

  register_for :lua
  file_extension "lua"
  title "Lua"

  # http://www.lua.org/manual/5.2/manual.html#3.1
  KEYWORDS = %w[
    and break do else elseif end
    for function goto if in
    local not or repeat return
    then until while
  ]

  # http://www.lua.org/manual/5.2/manual.html#3.1
  CONSTANTS = %w[false true nil]

  # http://www.lua.org/manual/5.2/manual.html#6.1
  LIBRARY = %w[
  assert collectgarbage dofile error getmetatable
  ipairs load loadfile next pairs pcall print
  rawequal rawget rawlen rawset select setmetatable
  tonumber tostring type xpcall
  ]

  SCANNER = /
    (?<space>\s*)      # eat leading whitespace, just to make iteration of fluff easier
    (?<fluff>[\d\D]*?) # eat content up until something we want
    (?:
      \b(?<keyword>#{KEYWORDS.join('|')})\b
      |
      (?: # strings
        (?<s1q1>")
        (?<s1>(?:[^\\"\n]|\\[abfnrtvz\\"']|\\\n|\\\d{1,3}|\\x[\da-fA-F]{2})*)
        (?<s1q2>")
        |
        (?<s2q1>')
        (?<s2>(?:[^\\'\n]|\\[abfnrtvz\\"']|\\\n|\\\d{1,3}|\\x[\da-fA-F]{2})*)
        (?<s2q2>')
        |
        (?<s3q1>\[(?<stringequals>=*)\[)
        (?<s3>[\d\D]*?)                  # Not using multiline mode due to single-line comments
        (?<s3q2>\]\k<stringequals>\])
      )
      |
      \b(?<number>
        -? # Allows -2 to be properly highlighted, but makes 10-5 show -5 as a single number
        (?:
          0[xX]
          (?:
            [\da-fA-F]+\.?[\da-fA-F]*  # 0xA and 0xA. and 0xA.1
            |
            \.[\da-fA-F]+              # 0x.A
          )
          (?:[pP][-+]?\d+)?            # 0xA.1p-3
          |
          (?:
            \d+\.?\d*                  # 3 and 3. and 3.14
            |
            \.\d+                      # .3
          )
          (?:[eE][-+]?\d+)?            # 3.1e-7
        )
      )\b
      |
      (?:
        (?<blockcommentstart>--\[(?<commentequals>=*)\[)
        (?<blockcommentmain>[\d\D]*?) # Not using multiline mode due to single-line comments
        (?<blockcommentclose>\]\k<commentequals>\])
      )
      |
      (?<comment>
        --(?!\[).+
      )
      |
      \b(?<constant>#{CONSTANTS.join('|')})\b
      |
      \b(?<library>#{LIBRARY.join('|')})\b
      |
      (?<operators>
        (?<!\.)\.{2,3}(?!\.)
        |
        (?<!=)={1,2}(?!=)
        |
        [+\-*\/%^#]
        |
        ~=
        |
        [<>]=?
      )
      |
      (?<reserved>
        \b_[A-Z]+\b                    # _VERSION
      )
      |
      (?<gotolabel>
        ::[a-zA-Z_]\w*::
      )
    )
  /x

  CAPTURE_KINDS = {
    reserved:     :reserved,
    comment:      :comment,
    blockcommentstart: {
      _group:     :comment,
      blockcommentstart: :delimiter,
      blockcommentmain:  :content,
      blockcommentclose: :delimiter
    },
    keyword:      :keyword,
    number:       :float,
    constant:     :"predefined-constant",
    library:      :predefined,
    s1q1:         {
      _group:     :string,
      s1q1:       :delimiter,
      s1:         :content,
      s1q2:       :delimiter,
    },
    s2q1:         {
      _group:     :string,
      s2q1:       :delimiter,
      s2:         :content,
      s2q2:       :delimiter,
    },
    s3q1:         {
      _group:     :string,
      s3q1:       :delimiter,
      s3:         :content,
      s3q2:       :delimiter,
    },
    gotolabel:    :label,
    operators:    :operator,
  }

  protected

  def scan_tokens(tokens, options)
    # We use the block form of gsub instead of the StringScanner capabilities because StringScanner does not support named captures in 1.9
    string.gsub(SCANNER) do
      match = $~
      tokens.text_token( match[:space], :space ) unless match[:space].empty?
      unless match[:fluff].empty?
        space = false
        match[:fluff].split(/(\s+)/).each do |piece|
          tokens.text_token(piece, space ? :space : :content)
          space = !space
        end
      end
      CAPTURE_KINDS.each do |capture,kind|
        next unless match[capture] && !match[capture].empty?
        if kind.is_a? Hash
          tokens.begin_group(kind[:_group])
          kind.each do |c,k|
            tokens.text_token( match[c], k ) unless c==:_group
          end
          tokens.end_group(kind[:_group])
        else
          tokens.text_token( match[capture], kind )
        end
      end
    end
    tokens
  end

end