($:.unshift '../..'; require 'coderay') unless defined? CodeRay
module CodeRay
module Encoders
  
  # Concats the tokens into a single string, resulting in the original
  # code string if no tokens were removed.
  # 
  # Alias: +plain+
  # 
  # == Options
  # 
  # === :separator
  # A separator string to join the tokens.
  # 
  # Default: empty String
  class Text < Encoder

    register_for :text

    FILE_EXTENSION = 'txt'

    DEFAULT_OPTIONS = {
      :separator => nil
    }

    def text_token text, kind
      @out << text
      @out << @sep if @sep
    end

  protected
    def setup options
      super
      @sep = options[:separator]
    end

    def finish options
      super.chomp @sep
    end

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
    ruby = <<-RUBY
puts "Hello world!"
    RUBY
    tokens = CodeRay.scan ruby, :ruby
    assert_equal ruby, tokens.encode_with(:text)
  end
  
end