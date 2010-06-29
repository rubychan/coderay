require 'test/unit'
require 'coderay'

class FilterTest < Test::Unit::TestCase
  
  def test_creation
    filter = nil
    assert_nothing_raised do
      filter = CodeRay.encoder :filter
    end
    assert CodeRay::Encoders::Filter < CodeRay::Encoders::Encoder
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
