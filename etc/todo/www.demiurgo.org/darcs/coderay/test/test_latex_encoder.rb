require 'test/unit'
require 'coderay'

class TC_Latex_Encoder < Test::Unit::TestCase
  def setup
    CodeRay::Encoders.plugin_path 'lib/coderay/encoders'
    @enc = CodeRay::Encoders[:latex].new
  end


  def test_escape_latex
    tests = {"I have $30, and new\\\nline" => "I have \\$30, and new\\synbs{}\nline",
             'I like "clean & simple" things just best than {obscure,complicated}' => 'I like "{}clean \& simple"{} things just best than \{obscure,complicated\}',
             "The string '\\'' is valid... in C" => "The string '\\synbs{}'' is valid... in C",
             "Escape dollars as \\$, and continue line, backslash at the end, like so: \\\n" => "Escape dollars as \\synbs{}\\$, and continue line, backslash at the end, like so: \\synbs{}\n",
             "Perl: $foo{some_key} =~ /^#.*$/" => "Perl: \\$foo\\{some\\_key\\} =\\~{} /\\^{}\\#.*\\$/",
             "Double backslash escaping: \\\\" => "Double backslash escaping: \\synbs{}\\synbs{}",
             "\"Some\nmultiline\nstring\"" => "\"{}Some\nmultiline\nstring\"{}",
             "printf(\"Hello, World\\n\");" => "printf(\"{}Hello, World\\synbs{}n\"{});"}
    tests.each_pair do |k,v|
      assert_equal(v, @enc.send(:escape_latex, k))
    end
  end


  def test_simple
    source_text = <<EOD
require 'coderay'

# scan some code
tokens = CodeRay.scan('some_file.rb', :ruby)

# dump using LaTeX
puts tokens.latex
EOD
    expected = [["require", :ident], [" ", :space], [:open, :string],
                ["'", :delimiter], ["coderay", :content], ["'", :delimiter],
                [:close, :string], ["\n\n", :space],
                ["# scan some code", :comment], ["\n", :space],
                ["tokens", :ident], [" ", :space], ["=", :operator],
                [" ", :space], ["CodeRay", :constant], [".", :operator],
                ["scan", :ident], ["(", :operator], [:open, :string],
                ["'", :delimiter], ["some_file.rb", :content],
                ["'", :delimiter], [:close, :string], [",", :operator],
                [" ", :space], [":ruby", :symbol], [")", :operator],
                ["\n\n", :space], ["# dump using LaTeX", :comment],
                ["\n", :space], ["puts", :ident], [" ", :space],
                ["tokens", :ident], [".", :operator], ["latex", :ident],
                ["\n", :space]]
    symbol_list = CodeRay.scan(source_text, :ruby)
    assert_equal(expected, symbol_list)

    expected_latex = <<'EOD'
\begin{semiverbatim}
\synident{require} \synstring{\syndelimiter{'}\syncontent{coderay}\syndelimiter{'}}

\syncomment{\# scan some code}
\synident{tokens} \synoperator{=} \synconstant{CodeRay}\synoperator{.}\synident{scan}\synoperator{(}\synstring{\syndelimiter{'}\syncontent{some\_file.rb}\syndelimiter{'}}\synoperator{,} \synsymbol{:ruby}\synoperator{)}

\syncomment{\# dump using LaTeX}
\synident{puts} \synident{tokens}\synoperator{.}\synident{latex}

\end{semiverbatim}
EOD
    assert_equal(expected_latex, symbol_list.latex)
  end

  def test_wrap
    source_text = <<EOD
require 'coderay'

# scan some code
tokens = CodeRay.scan('some_file.rb', :ruby)

# dump using LaTeX
puts tokens.latex
EOD

    expected_latex = <<'EOD'
\synident{require} \synstring{\syndelimiter{'}\syncontent{coderay}\syndelimiter{'}}

\syncomment{\# scan some code}
\synident{tokens} \synoperator{=} \synconstant{CodeRay}\synoperator{.}\synident{scan}\synoperator{(}\synstring{\syndelimiter{'}\syncontent{some\_file.rb}\syndelimiter{'}}\synoperator{,} \synsymbol{:ruby}\synoperator{)}

\syncomment{\# dump using LaTeX}
\synident{puts} \synident{tokens}\synoperator{.}\synident{latex}
EOD
    expected_latex2 = <<EOD
\\begin{semiverbatim}
#{expected_latex}
\\end{semiverbatim}
EOD
    symbols = CodeRay.scan(source_text, :ruby)
    assert_equal(expected_latex, symbols.latex(:wrap => false))
    assert_equal(expected_latex2, symbols.latex)
    assert_equal(expected_latex2, symbols.latex(:wrap => true))
    assert_equal(expected_latex2, symbols.latex(:wrap => :semiverbatim))
  end

  def teardown
    @enc = nil
  end
end
