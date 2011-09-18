require 'test/unit'
require 'coderay'

class NullTest < Test::Unit::TestCase
  
  def test_null
    ruby = <<-RUBY
puts "Hello world!"
    RUBY
    tokens = CodeRay.scan ruby, :ruby
    assert_equal '', tokens.encode(:null)
  end
  
end