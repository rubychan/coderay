($:.unshift '../..'; require 'coderay') unless defined? CodeRay
module CodeRay
module Encoders
  
  # A Filter encoder has another Tokens instance as output.
  # It can be subclass to select, remove, or modify tokens in the stream.
  # 
  # Subclasses of Filter are called "Filters" and can be chained.
  # 
  # == Options
  # 
  # === :tokens
  # 
  # The Tokens object which will receive the output.
  # 
  # Default: Tokens.new
  # 
  # See also: TokenKindFilter
  class Filter < Encoder
    
    register_for :filter
    
  protected
    def setup options
      @out = options[:tokens] || Tokens.new
    end
    
  public
    
    def text_token text, kind  # :nodoc:
      @out.text_token text, kind
    end
    
    def begin_group kind  # :nodoc:
      @out.begin_group kind
    end
    
    def begin_line kind  # :nodoc:
      @out.begin_line kind
    end
    
    def end_group kind  # :nodoc:
      @out.end_group kind
    end
    
    def end_line kind  # :nodoc:
      @out.end_line kind
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

class FilterTest < Test::Unit::TestCase
  
  def test_creation
    assert CodeRay::Encoders::Filter < CodeRay::Encoders::Encoder
    filter = nil
    assert_nothing_raised do
      filter = CodeRay.encoder :filter
    end
    assert_kind_of CodeRay::Encoders::Encoder, filter
  end
  
  def test_filtering_text_tokens
    tokens = CodeRay::Tokens.new
    10.times do |i|
      tokens.text_token i.to_s, :index
    end
    assert_equal tokens, CodeRay::Encoders::Filter.new.encode_tokens(tokens)
    assert_equal tokens, tokens.filter
  end
  
  def test_filtering_block_tokens
    tokens = CodeRay::Tokens.new
    10.times do |i|
      tokens.begin_group :index
      tokens.text_token i.to_s, :content
      tokens.end_group :index
      tokens.begin_line :index
      tokens.text_token i.to_s, :content
      tokens.end_line :index
    end
    assert_equal tokens, CodeRay::Encoders::Filter.new.encode_tokens(tokens)
    assert_equal tokens, tokens.filter
  end
  
end
