# -*- coding: utf-8 -*-

# Scanner for the Lua[http://lua.org] programming lanuage.
#
# The language’s complete syntax is defined in
# {the Lua manual}[http://www.lua.org/manual/5.2/manual.html],
# which is what this scanner tries to conform to.
class CodeRay::Scanners::Lua < CodeRay::Scanners::Scanner

  register_for :lua
  file_extension "lua"
  title "Lua"

  KEYWORDS = %w[
    and break do else elseif end
    for function goto if in
    local not or repeat return
    then until while
  ]

  PREDEFINED_CONSTANTS = %w[false true nil]

  PREDEFINED_EXPRESSIONS = %w[
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
      (?<blockcomment>
        --\[(?<commentequals>=*)\[[\d\D]*?\]\k<commentequals>\]
      )
      |
      (?:
        (?<s1q1>")(?<s1>(?:[^\\"\n]|\\[abfnrtvz\\"']|\\\n|\\\d{1,3}|\\x[\da-fA-F]{2})*)(?<s1q2>")
        |
        (?<s2q1>')(?<s2>(?:[^\\'\n]|\\[abfnrtvz\\"']|\\\n|\\\d{1,3}|\\x[\da-fA-F]{2})*)(?<s2q2>')
        |
        (?<s3q1>\[(?<stringequals>=*)\[)(?<s3>[\d\D]*?)(?<s3q2>\]\k<stringequals>\])
      )
      |
      (?<comment>
        --(?!\[).+
      )
      |
      \b(?<number>
        -? # Allows -2 to be properly highlighted, but makes 10-5 show -5 as a single number
        (?:
          0[xX]
          (?:
            [\da-fA-F]+\.?[\da-fA-F]*
            |
            [\da-fA-F]*\.[\da-fA-F]+
          )
          (?:[pP][-+]?\d+)?
          |
          (?:
            \d+\.?\d*
            |
            \d*\.\d+
          )
          (?:[eE][-+]?\d+)?
        )
      )\b
      |
      \b(?<constant>#{PREDEFINED_CONSTANTS.join('|')})\b
      |
      \b(?<library>#{PREDEFINED_EXPRESSIONS.join('|')})\b
      |
      (?<gotolabel>
        ::[a-zA-Z_]\w*::
      )
      |
      (?<reserved>
        \b_[A-Z]+\b
      )
    )
  /x

  CAPTURE_KINDS = {
    reserved:     :reserved,
    comment:      :comment,
    blockcomment: :comment,
    keyword:      :keyword,
    number:       :float,
    constant:     :"predefined-constant",
    library:      :predefined,
    s1q1:         :delimiter,
    s1:           :string,
    s1q2:         :delimiter,
    s2q1:         :delimiter,
    s2:           :string,
    s2q2:         :delimiter,
    s3q1:         :delimiter,
    s3:           :string,
    s3q2:         :delimiter,
    gotolabel:    :label,
  }

  protected

  def scan_tokens(tokens, options)
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
        tokens.text_token( match[capture], kind ) if match[capture] && !match[capture].empty?
      end
    end
    tokens
  end

end