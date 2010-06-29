require 'test/unit'
require 'coderay/tokens'

class TokensTest < Test::Unit::TestCase
  
  def test_creation
    assert CodeRay::Tokens < Array
    tokens = nil
    assert_nothing_raised do
      tokens = CodeRay::Tokens.new
    end
    assert_kind_of Array, tokens
  end
  
  def test_adding_tokens
    tokens = CodeRay::Tokens.new
    assert_nothing_raised do
      tokens.text_token 'string', :type
      tokens.text_token '()', :operator
    end
    assert_equal tokens.size, 4
    assert_equal tokens.count, 2
  end
  
  def test_dump_undump
    tokens = CodeRay::Tokens.new
    assert_nothing_raised do
      tokens.text_token 'string', :type
      tokens.text_token '()', :operator
    end
    tokens2 = nil
    assert_nothing_raised do
      tokens2 = tokens.dump.undump
    end
    assert_equal tokens, tokens2
  end
  
end