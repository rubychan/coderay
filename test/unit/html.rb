require 'test/unit'
require 'coderay'

class HtmlTest < Test::Unit::TestCase
  
  def test_break_lines_option
    snippets = {}
    
    snippets[:ruby] = {}
    
    snippets[:ruby][:in] = <<-RUBY
ruby_inside = <<-RUBY_INSIDE
This is tricky,
isn't it?
RUBY_INSIDE
    RUBY
    
    snippets[:ruby][:expected_with_option_off] = <<-HTML_OPT_INDEPENDENT_LINES_OFF
ruby_inside = <span class=\"string\"><span class=\"delimiter\">&lt;&lt;-RUBY_INSIDE</span></span><span class=\"string\"><span class=\"content\">
This is tricky,
isn't it?</span><span class=\"delimiter\">
RUBY_INSIDE</span></span>
    HTML_OPT_INDEPENDENT_LINES_OFF
    
    snippets[:ruby][:expected_with_option_on] = <<-HTML_OPT_INDEPENDENT_LINES_ON
ruby_inside = <span class=\"string\"><span class=\"delimiter\">&lt;&lt;-RUBY_INSIDE</span></span><span class=\"string\"><span class=\"content\"></span></span>
<span class=\"string\"><span class=\"content\">This is tricky,</span></span>
<span class=\"string\"><span class=\"content\">isn't it?</span><span class=\"delimiter\"></span></span>
<span class=\"string\"><span class=\"delimiter\">RUBY_INSIDE</span></span>
    HTML_OPT_INDEPENDENT_LINES_ON
    
    snippets[:java] = {}
    
    snippets[:java][:in] = <<-JAVA
import java.lang.*;

/**
 * This is some multiline javadoc
 * used to test the
 */
public class Test {
  public static final String MESSAGE = "My message\
    To the world";

  static void main() {
    /*
     * Another multiline
     * comment
     */
    System.out.println(MESSAGE);
  }
}
    JAVA
    
    snippets[:java][:expected_with_option_off] = <<-HTML_OPT_INDEPENDENT_LINES_OFF
<span class=\"keyword\">import</span> <span class=\"include\">java.lang</span>.*;

<span class=\"comment\">/**
 * This is some multiline javadoc
 * used to test the
 */</span>
<span class=\"directive\">public</span> <span class=\"type\">class</span> <span class=\"class\">Test</span> {
  <span class=\"directive\">public</span> <span class=\"directive\">static</span> <span class=\"directive\">final</span> <span class=\"predefined-type\">String</span> MESSAGE = <span class=\"string\"><span class=\"delimiter\">&quot;</span><span class=\"content\">My message    To the world</span><span class=\"delimiter\">&quot;</span></span>;

  <span class=\"directive\">static</span> <span class=\"type\">void</span> main() {
    <span class=\"comment\">/*
     * Another multiline
     * comment
     */</span>
    <span class=\"predefined-type\">System</span>.out.println(MESSAGE);
  }
}
    HTML_OPT_INDEPENDENT_LINES_OFF
    
    snippets[:java][:expected_with_option_on] = <<-HTML_OPT_INDEPENDENT_LINES_ON
<span class=\"keyword\">import</span> <span class=\"include\">java.lang</span>.*;

<span class=\"comment\">/**</span>
<span class=\"comment\"> * This is some multiline javadoc</span>
<span class=\"comment\"> * used to test the</span>
<span class=\"comment\"> */</span>
<span class=\"directive\">public</span> <span class=\"type\">class</span> <span class=\"class\">Test</span> {
  <span class=\"directive\">public</span> <span class=\"directive\">static</span> <span class=\"directive\">final</span> <span class=\"predefined-type\">String</span> MESSAGE = <span class=\"string\"><span class=\"delimiter\">&quot;</span><span class=\"content\">My message    To the world</span><span class=\"delimiter\">&quot;</span></span>;

  <span class=\"directive\">static</span> <span class=\"type\">void</span> main() {
    <span class=\"comment\">/*</span>
<span class=\"comment\">     * Another multiline</span>
<span class=\"comment\">     * comment</span>
<span class=\"comment\">     */</span>
    <span class=\"predefined-type\">System</span>.out.println(MESSAGE);
  }
}
    HTML_OPT_INDEPENDENT_LINES_ON
    
    for lang, code in snippets
      tokens = CodeRay.scan code[:in], lang
      
      assert_equal code[:expected_with_option_off], tokens.html
      assert_equal code[:expected_with_option_off], tokens.html(:break_lines => false)
      assert_equal code[:expected_with_option_on],  tokens.html(:break_lines => true)
    end
  end
end
