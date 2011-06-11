require 'test/unit'
require 'coderay'

class DuoTest < Test::Unit::TestCase
  
  def test_two_arguments
    duo = CodeRay::Duo[:ruby, :html]
    assert_kind_of CodeRay::Scanners[:ruby], duo.scanner
    assert_kind_of CodeRay::Encoders[:html], duo.encoder
  end
  
  def test_two_hash
    duo = CodeRay::Duo[:ruby => :html]
    assert_kind_of CodeRay::Scanners[:ruby], duo.scanner
    assert_kind_of CodeRay::Encoders[:html], duo.encoder
  end
  
  def test_call
    duo = CodeRay::Duo[:python => :xml]
    assert_equal <<-'XML'.chomp, duo.call('def test: "pass"')
<?xml version='1.0'?><coderay-tokens><keyword>def</keyword> <method>test</method><operator>:</operator> <string><delimiter>&quot;</delimiter><content>pass</content><delimiter>&quot;</delimiter></string></coderay-tokens>
    XML
  end
  
end
