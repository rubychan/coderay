require 'test/unit'
require 'coderay'

class CountTest < Test::Unit::TestCase
  
  def test_count
    tokens = CodeRay.scan <<-RUBY.strip, :ruby
#!/usr/bin/env ruby
# a minimal Ruby program
puts "Hello world!"
    RUBY
    assert_equal 11, tokens.encode(:count)
  end
  
end