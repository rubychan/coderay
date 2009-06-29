require "test/unit"
require "coderay"

class BasicTest < Test::Unit::TestCase
  
  def test_version
    assert_nothing_raised do
      assert_match(/\A\d\.\d\.\d\z/, CodeRay::VERSION)
    end
  end
  
  RUBY_TEST_CODE = 'puts "Hello, World!"'
  
  def test_simple_scan
    assert_nothing_raised do
      CodeRay.scan(RUBY_TEST_CODE, :ruby)
    end
  end
  
  def test_simple_highlight
    assert_nothing_raised do
      CodeRay.scan(RUBY_TEST_CODE, :ruby).html
    end
  end
  
  def test_duo
    assert_equal(RUBY_TEST_CODE,
      CodeRay::Duo[:plain, :plain].highlight(RUBY_TEST_CODE))
    assert_equal(RUBY_TEST_CODE,
      CodeRay::Duo[:plain => :plain].highlight(RUBY_TEST_CODE))
  end
  
  def test_duo_stream
    assert_equal(RUBY_TEST_CODE,
      CodeRay::Duo[:plain, :plain].highlight(RUBY_TEST_CODE, :stream => true))
  end
  
  def test_comment_filter
    assert_equal <<-EXPECTED, CodeRay.scan(<<-INPUT, :ruby).comment_filter.text
#!/usr/bin/env ruby

code

more code  
      EXPECTED
#!/usr/bin/env ruby
=begin
A multi-line comment.
=end
code
# A single-line comment.
more code  # and another comment, in-line.
      INPUT
  end
  
  def test_lines_of_code
    assert_equal 2, CodeRay.scan(<<-INPUT, :ruby).lines_of_code
#!/usr/bin/env ruby
=begin
A multi-line comment.
=end
code
# A single-line comment.
more code  # and another comment, in-line.
      INPUT
  end
  
  begin
    require 'rubygems'
    gem 'RedCloth', '>= 4.0.3' rescue nil
    require 'redcloth'
    
    def test_for_redcloth
      require 'rubygems'
      require 'coderay/for_redcloth'
      assert_equal "<p><span lang=\"ruby\" class=\"CodeRay\">puts <span style=\"background-color:#fff0f0;color:#D20\"><span style=\"color:#710\">\"</span><span style=\"\">Hello, World!</span><span style=\"color:#710\">\"</span></span></span></p>",
        RedCloth.new('@[ruby]puts "Hello, World!"@').to_html
      assert_equal <<-BLOCKCODE.chomp,
<div lang="ruby" class="CodeRay">
  <div class="code"><pre>puts <span style="background-color:#fff0f0;color:#D20"><span style="color:#710">&quot;</span><span style="">Hello, World!</span><span style="color:#710">&quot;</span></span></pre></div>
</div>
        BLOCKCODE
        RedCloth.new('bc[ruby]. puts "Hello, World!"').to_html
    end
    
    def test_for_redcloth_no_lang
      require 'rubygems'
      require 'coderay/for_redcloth'
      assert_equal "<p><code>puts \"Hello, World!\"</code></p>",
        RedCloth.new('@puts "Hello, World!"@').to_html
      assert_equal <<-BLOCKCODE.chomp,
<pre><code>puts \"Hello, World!\"</code></pre>
        BLOCKCODE
        RedCloth.new('bc. puts "Hello, World!"').to_html
    end
    
    def test_for_redcloth_style
      require 'rubygems'
      require 'coderay/for_redcloth'
      assert_equal <<-BLOCKCODE.chomp,
<pre style=\"color: red;\"><code style=\"color: red;\">puts \"Hello, World!\"</code></pre>
        BLOCKCODE
        RedCloth.new('bc{color: red}. puts "Hello, World!"').to_html
    end
    
    def test_for_redcloth_escapes
      require 'rubygems'
      require 'coderay/for_redcloth'
      assert_equal '<p><span lang="ruby" class="CodeRay">&gt;</span></p>',
        RedCloth.new('@[ruby]>@').to_html
      assert_equal <<-BLOCKCODE.chomp,
<div lang="ruby" class="CodeRay">
  <div class="code"><pre>&amp;</pre></div>
</div>
        BLOCKCODE
        RedCloth.new('bc[ruby]. &').to_html
    end
  rescue LoadError
    $stderr.puts 'RedCloth not found - skipping for_redcloth tests.'
  end
  
  def test_list_of_encoders
    assert_kind_of(Array, CodeRay::Encoders.list)
    assert CodeRay::Encoders.list.include?('count')
  end
  
  def test_list_of_scanners
    assert_kind_of(Array, CodeRay::Scanners.list)
    assert CodeRay::Scanners.list.include?('plaintext')
  end
  
end
