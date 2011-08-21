require 'test/unit'
require 'yaml'
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
    duo = CodeRay::Duo[:python => :yml]
    yaml = [["def", :keyword],
            [" ", :space],
            ["test", :method],
            [":", :operator],
            [" ", :space],
            [:begin_group, :string],
            ["\"", :delimiter],
            ["pass", :content],
            ["\"", :delimiter],
            [:end_group, :string]]
    
    assert_equal yaml, YAML.load(duo.call('def test: "pass"'))
  end
  
end
