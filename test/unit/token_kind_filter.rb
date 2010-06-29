require 'test/unit'
require 'coderay'

class TokenKindFilterTest < Test::Unit::TestCase
  
  def test_creation
    assert CodeRay::Encoders::TokenKindFilter < CodeRay::Encoders::Encoder
    assert CodeRay::Encoders::TokenKindFilter < CodeRay::Encoders::Filter
    filter = nil
    assert_nothing_raised do
      filter = CodeRay.encoder :token_kind_filter
    end
    assert_instance_of CodeRay::Encoders::TokenKindFilter, filter
  end
  
  def test_filtering_text_tokens
    tokens = CodeRay::Tokens.new
    for i in 1..10
      tokens.text_token i.to_s, :index
      tokens.text_token ' ', :space if i < 10
    end
    assert_equal 10, CodeRay::Encoders::TokenKindFilter.new.encode_tokens(tokens, :exclude => :space).count
    assert_equal 10, tokens.token_kind_filter(:exclude => :space).count
    assert_equal 9, CodeRay::Encoders::TokenKindFilter.new.encode_tokens(tokens, :include => :space).count
    assert_equal 9, tokens.token_kind_filter(:include => :space).count
    assert_equal 0, CodeRay::Encoders::TokenKindFilter.new.encode_tokens(tokens, :exclude => :all).count
    assert_equal 0, tokens.token_kind_filter(:exclude => :all).count
  end
  
  def test_filtering_block_tokens
    tokens = CodeRay::Tokens.new
    10.times do |i|
      tokens.begin_group :index
      tokens.text_token i.to_s, :content
      tokens.end_group :index
      tokens.begin_group :naught if i == 5
      tokens.end_group :naught if i == 7
      tokens.begin_line :blubb
      tokens.text_token i.to_s, :content
      tokens.end_line :blubb
    end
    assert_equal 16, CodeRay::Encoders::TokenKindFilter.new.encode_tokens(tokens, :include => :blubb).count
    assert_equal 16, tokens.token_kind_filter(:include => :blubb).count
    assert_equal 24, CodeRay::Encoders::TokenKindFilter.new.encode_tokens(tokens, :include => [:blubb, :content]).count
    assert_equal 24, tokens.token_kind_filter(:include => [:blubb, :content]).count
    assert_equal 32, CodeRay::Encoders::TokenKindFilter.new.encode_tokens(tokens, :exclude => :index).count
    assert_equal 32, tokens.token_kind_filter(:exclude => :index).count
  end
  
end
