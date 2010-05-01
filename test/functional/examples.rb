require 'test/unit'
require 'coderay'

class ExamplesTest < Test::Unit::TestCase
  
  def test_examples
    # output as HTML div (using inline CSS styles)
    div = CodeRay.scan('puts "Hello, world!"', :ruby).div
    assert_equal <<-DIV, div
<div class="CodeRay">
  <div class="code"><pre>puts <span style="background-color:hsla(0,100%,50%,0.1);color:#D20"><span style="color:#710">&quot;</span><span style="">Hello, world!</span><span style="color:#710">&quot;</span></span></pre></div>
</div>
    DIV
    
    # ...with line numbers
    div = CodeRay.scan(<<-CODE.chomp, :ruby).div(:line_numbers => :table)
5.times do
  puts 'Hello, world!'
end
    CODE
    assert_equal <<-DIV, div
<table class="CodeRay"><tr>
  <td class="line_numbers" title="double click to toggle" ondblclick="with (this.firstChild.style) { display = (display == '') ? 'none' : '' }"><pre><a href="#n1" name="n1">1</a>
<a href="#n2" name="n2">2</a>
<a href="#n3" name="n3">3</a>
</pre></td>
  <td class="code"><pre ondblclick="with (this.style) { overflow = (overflow == 'auto' || overflow == '') ? 'visible' : 'auto' }"><span style="color:#00D;font-weight:bold">5</span>.times <span style="color:#080;font-weight:bold">do</span>
  puts <span style="background-color:hsla(0,100%,50%,0.1);color:#D20"><span style="color:#710">'</span><span style="">Hello, world!</span><span style="color:#710">'</span></span>
<span style="color:#080;font-weight:bold">end</span></pre></td>
</tr></table>
    DIV
    
    # output as standalone HTML page (using CSS classes)
    page = CodeRay.scan('puts "Hello, world!"', :ruby).page
    assert_equal <<-PAGE, page
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>CodeRay output</title>
  <style type="text/css">
.CodeRay .line_numbers a, .CodeRay .no a {
  text-decoration: inherit;
  color: inherit;
}
.CodeRay {
  background-color: #f8f8f8;
  border: 1px solid silver;
  font-family: 'Courier New', 'Terminal', monospace;
  color: #000;
}
.CodeRay pre { margin: 0px; }

span.CodeRay { white-space: pre; border: 0px; padding: 2px; }

table.CodeRay { border-collapse: collapse; width: 100%; padding: 2px; }
table.CodeRay td { padding: 2px 4px; vertical-align: top; }

.CodeRay .line_numbers, .CodeRay .no {
  background-color: #def;
  color: gray;
  text-align: right;
}
.CodeRay .line_numbers a:target, .CodeRay .no a:target { color: blue; }
.CodeRay .line_numbers .highlighted, .CodeRay .no .highlighted { color: red; }
.CodeRay .no { padding: 0px 4px; }
.CodeRay .code { width: 100%; }
.CodeRay .code pre { overflow: auto; }

.CodeRay .debug { color:white ! important; background:blue ! important; }

.CodeRay .an { color:#007 }
.CodeRay .at { color:#f08 }
.CodeRay .av { color:#700 }
.CodeRay .bi { color:#509; font-weight:bold }
.CodeRay .c  { color:#888; }
.CodeRay .c .dl { color:#444; }
.CodeRay .c .ch { color:#444; }

.CodeRay .ch { color:#04D }
.CodeRay .ch .k { color:#04D }
.CodeRay .ch .dl { color:#039 }

.CodeRay .cl { color:#B06; font-weight:bold }
.CodeRay .cm { color:#A08; font-weight:bold }
.CodeRay .co { color:#036; font-weight:bold }
.CodeRay .cr { color:#0A0 }
.CodeRay .cv { color:#369 }
.CodeRay .de { color:#B0B; }
.CodeRay .df { color:#099; font-weight:bold }
.CodeRay .di { color:#088; font-weight:bold }
.CodeRay .dl { color:black }
.CodeRay .do { color:#970 }
.CodeRay .dt { color:#34b }
.CodeRay .ds { color:#D42; font-weight:bold }
.CodeRay .e  { color:#666; font-weight:bold }
.CodeRay .en { color:#800; font-weight:bold }
.CodeRay .er { color:#F00; background-color:#FAA }
.CodeRay .ex { color:#C00; font-weight:bold }
.CodeRay .fl { color:#60E; font-weight:bold }
.CodeRay .fu { color:#06B; font-weight:bold }
.CodeRay .gv { color:#d70; font-weight:bold }
.CodeRay .hx { color:#058; font-weight:bold }
.CodeRay .i  { color:#00D; font-weight:bold }
.CodeRay .ic { color:#B44; font-weight:bold }

.CodeRay .il { background-color: hsla(0,0%,0%,0.1); color: black }
.CodeRay .il .idl { font-weight: bold; color: #666 }
.CodeRay .idl { font-weight: bold; color: #666; }

.CodeRay .im { color:#f00; }
.CodeRay .in { color:#B2B; font-weight:bold }
.CodeRay .iv { color:#33B }
.CodeRay .la { color:#970; font-weight:bold }
.CodeRay .lv { color:#963 }
.CodeRay .ns { color:#707; font-weight:bold }
.CodeRay .oc { color:#40E; font-weight:bold }
.CodeRay .op { }
.CodeRay .pc { color:#058; font-weight:bold }
.CodeRay .pd { color:#369; font-weight:bold }
.CodeRay .pp { color:#579; }
.CodeRay .ps { color:#00C; font-weight:bold }
.CodeRay .pt { color:#074; font-weight:bold }
.CodeRay .r, .kw  { color:#080; font-weight:bold }

.CodeRay .ke { color: #808; }
.CodeRay .ke .dl { color: #606; }
.CodeRay .ke .ch { color: #80f; }
.CodeRay .vl { color: #088; }

.CodeRay .rx { background-color:hsla(300,100%,50%,0.1); color:#808 }
.CodeRay .rx .k { }
.CodeRay .rx .dl { color:#404 }
.CodeRay .rx .mod { color:#C2C }
.CodeRay .rx .fu  { color:#404; font-weight: bold }

.CodeRay .s { background-color:hsla(0,100%,50%,0.1); color: #D20; }
.CodeRay .s .k { }
.CodeRay .s .ch { color: #b0b; }
.CodeRay .s .dl { color: #710; }

.CodeRay .sh { background-color:hsla(120,100%,50%,0.1); color:#2B2 }
.CodeRay .sh .k { }
.CodeRay .sh .dl { color:#161 }

.CodeRay .sy { color:#A60 }
.CodeRay .sy .k { color:#A60 }
.CodeRay .sy .dl { color:#630 }

.CodeRay .ta { color:#070 }
.CodeRay .ts { color:#D70; font-weight:bold }
.CodeRay .ty { color:#339; font-weight:bold }
.CodeRay .v  { color:#036 }
.CodeRay .xt { color:#444 }

.CodeRay .ins { background: #afa; }
.CodeRay .del { background: #faa; }
.CodeRay .chg { color: #aaf; background: #007; }
.CodeRay .head { color: #f8f; background: #505 }
.CodeRay .head .filename { color: white; }

.CodeRay .ins .ins { color: #080; font-weight:bold }
.CodeRay .del .del { color: #800; font-weight:bold }
.CodeRay .chg .chg { color: #66f; }
.CodeRay .head .head { color: #f4f; }

  </style>
</head>
<body style="background-color: white;">

<table class="CodeRay"><tr>
  <td class="line_numbers" title="double click to toggle" ondblclick="with (this.firstChild.style) { display = (display == '') ? 'none' : '' }"><pre>
</pre></td>
  <td class="code"><pre ondblclick="with (this.style) { overflow = (overflow == 'auto' || overflow == '') ? 'visible' : 'auto' }">puts <span class="s"><span class="dl">&quot;</span><span class="k">Hello, world!</span><span class="dl">&quot;</span></span></pre></td>
</tr></table>

</body>
</html>
    PAGE
    
    # keep scanned tokens for later use
    tokens = CodeRay.scan('{ "just": "an", "example": 42 }', :json)
    assert_equal ["{", :operator, " ", :space, :begin_group, :key,
      "\"", :delimiter, "just", :content, "\"", :delimiter,
      :end_group, :key, ":", :operator, " ", :space,
      :begin_group, :string, "\"", :delimiter, "an", :content,
      "\"", :delimiter, :end_group, :string, ",", :operator,
      " ", :space, :begin_group, :key, "\"", :delimiter,
      "example", :content, "\"", :delimiter, :end_group, :key,
      ":", :operator, " ", :space, "42", :integer,
      " ", :space, "}", :operator], tokens

    # produce a token statistic
    assert_equal <<-STATISTIC, tokens.statistic

Code Statistics

Tokens                  26
  Non-Whitespace        15
Bytes Total             31

Token Types (5):
  type                     count     ratio    size (average)
-------------------------------------------------------------
  TOTAL                       26  100.00 %     1.2
  delimiter                    6   23.08 %     1.0
  operator                     5   19.23 %     1.0
  space                        5   19.23 %     1.0
  begin_group                  3   11.54 %     0.0
  content                      3   11.54 %     4.3
  end_group                    3   11.54 %     0.0
  integer                      1    3.85 %     2.0

    STATISTIC
    
    # count the tokens
    assert_equal 26, tokens.count  # => 26
    
    # produce a HTML div, but with CSS classes
    div = tokens.div(:css => :class)
    assert_equal <<-DIV, div
<div class="CodeRay">
  <div class="code"><pre>{ <span class="ke"><span class="dl">&quot;</span><span class="k">just</span><span class="dl">&quot;</span></span>: <span class="s"><span class="dl">&quot;</span><span class="k">an</span><span class="dl">&quot;</span></span>, <span class="ke"><span class="dl">&quot;</span><span class="k">example</span><span class="dl">&quot;</span></span>: <span class="i">42</span> }</pre></div>
</div>
    DIV
    
    # highlight a file (HTML div); guess the file type base on the extension
    require 'coderay/helpers/file_type'
    assert_equal :ruby, CodeRay::FileType[__FILE__]
    
    # get a new scanner for Python
    python_scanner = CodeRay.scanner :python
    assert_kind_of CodeRay::Scanners::Python, python_scanner
    
    # get a new encoder for terminal
    terminal_encoder = CodeRay.encoder :term
    assert_kind_of CodeRay::Encoders::Terminal, terminal_encoder
    
    # scanning into tokens
    tokens = python_scanner.tokenize 'import this;  # The Zen of Python'
    assert_equal ["import", :keyword, " ", :space, "this", :include,
      ";", :operator, "  ", :space, "# The Zen of Python", :comment], tokens
    
    # format the tokens
    term = terminal_encoder.encode_tokens(tokens)
    assert_equal "\e[1;31mimport\e[0m \e[33mthis\e[0m;  \e[37m# The Zen of Python\e[0m", term
    
    # re-using scanner and encoder
    ruby_highlighter = CodeRay::Duo[:ruby, :div]
    div = ruby_highlighter.encode('puts "Hello, world!"')
    assert_equal <<-DIV, div
<div class="CodeRay">
  <div class="code"><pre>puts <span style="background-color:hsla(0,100%,50%,0.1);color:#D20"><span style="color:#710">&quot;</span><span style="">Hello, world!</span><span style="color:#710">&quot;</span></span></pre></div>
</div>
    DIV
  end
  
end
