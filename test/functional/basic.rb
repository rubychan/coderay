require "test/unit"
require "coderay"

class BasicTest < Test::Unit::TestCase
  def test_version
    assert_nothing_raised do
      CodeRay::VERSION
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
  end
  
  ENCODERS_LIST = %w(
    count debug div html null page span statistic text tokens xml yaml
  )
  def test_list_of_encoders
    assert_equal(ENCODERS_LIST, CodeRay::Encoders.list.sort)
  end

  SCANNERS_LIST = %w(
    c debug delphi html nitro_xhtml plaintext rhtml ruby xml
  )
  def test_list_of_scanners
    assert_equal(SCANNERS_LIST, CodeRay::Scanners.list.sort)
  end

end
