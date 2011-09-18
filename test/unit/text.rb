require 'test/unit'
require 'coderay'

class TextTest < Test::Unit::TestCase
  
  def test_count
    ruby = <<-RUBY
puts "Hello world!"
    RUBY
    tokens = CodeRay.scan ruby, :ruby
    assert_equal ruby, tokens.encode(:text)
  end
  
end