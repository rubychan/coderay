($:.unshift '../..'; require 'coderay') unless defined? CodeRay
module CodeRay
module Encoders
  
  # A Filter encoder has another Tokens instance as output.
  # It is used to select and delete tokens from the stream.
  # 
  # See also: TokenKindFilter
  class Filter < Encoder
    
    register_for :filter
    
  protected
    def setup options
      @out = Tokens.new
    end
    
    def include_text_token? text, kind
      true
    end
    
    def include_block_token? action, kind
      true
    end
    
  public
    
    def text_token text, kind
      @out.text_token text, kind if include_text_token? text, kind
    end
    
    def begin_group kind
      @out.begin_group kind if include_block_token? :begin_group, kind
    end
    
    def end_group kind
      @out.end_group kind if include_block_token? :end_group, kind
    end
    
    def begin_line kind
      @out.begin_line kind if include_block_token? :begin_line, kind
    end
    
    def end_line kind
      @out.end_line kind if include_block_token? :end_line, kind
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
    end
    assert_equal tokens, CodeRay::Encoders::Filter.new.encode_tokens(tokens)
    assert_equal tokens, tokens.filter
  end
  
end
