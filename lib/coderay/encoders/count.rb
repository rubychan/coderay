($:.unshift '../..'; require 'coderay') unless defined? CodeRay
module CodeRay
module Encoders
  
  # Returns the number of tokens.
  # 
  # Text and block tokens are counted.
  class Count < Encoder
    
    include Streamable
    register_for :count
    
  protected
    
    def setup options
      @out = 0
    end
    
    def text_token text, kind
      @out += 1
    end
    
    def begin_group kind
      @out += 1
    end
    alias end_group begin_group
    alias begin_line begin_group
    alias end_line begin_group
    
  end
  
end
end

if $0 == __FILE__
  $VERBOSE = true
  $: << File.join(File.dirname(__FILE__), '..')
  eval DATA.read, nil, $0, __LINE__ + 4
end

__END__
require 'test/unit'

class CountTest < Test::Unit::TestCase
  
  def test_count
    tokens = CodeRay.scan <<-RUBY.strip, :ruby
#!/usr/bin/env ruby
# a minimal Ruby program
puts "Hello world!"
    RUBY
    assert_equal 9, tokens.encode_with(:count)
  end
  
end