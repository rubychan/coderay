require 'test/unit'
require 'coderay'

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
    tokens = make_tokens
    assert_equal tokens.size, 8
    assert_equal tokens.count, 4
  end
  
  def test_dump_undump
    tokens = make_tokens
    tokens2 = nil
    assert_nothing_raised do
      tokens2 = tokens.dump.undump
    end
    assert_equal tokens, tokens2
  end
  
  def test_to_s
    assert_equal 'string()', make_tokens.to_s
  end
  
  def test_encode_with_nonsense
    assert_raise NoMethodError do
      make_tokens.nonsense
    end
  end
  
  def test_optimize
    assert_raise NotImplementedError do
      make_tokens.optimize
    end
    assert_raise NotImplementedError do
      make_tokens.optimize!
    end
  end
  
  def test_fix
    assert_raise NotImplementedError do
      make_tokens.fix
    end
    assert_raise NotImplementedError do
      make_tokens.fix!
    end
  end
  
  def test_split_into_lines
    assert_raise NotImplementedError do
      make_tokens.split_into_lines
    end
    assert_raise NotImplementedError do
      make_tokens.split_into_lines!
    end
  end
  
  def test_split_into_parts
    parts = [
      ["stri", :type],
      ["ng", :type, :begin_group, :operator, "(", :content, :end_group, :operator],
      [:begin_group, :operator, ")", :content, :end_group, :operator]
    ]
    assert_equal parts, make_tokens.split_into_parts(4, 3)
    assert_equal [make_tokens.to_a], make_tokens.split_into_parts
    
    line = CodeRay::Tokens[:begin_line, :head, '...', :plain]
    line_parts = [
      [:begin_line, :head, ".", :plain, :end_line, :head],
      [:begin_line, :head, "..", :plain]
    ]
    assert_equal line_parts, line.split_into_parts(1)
    
    assert_raise ArgumentError do
      CodeRay::Tokens[:bullshit, :input].split_into_parts
    end
    assert_raise ArgumentError do
      CodeRay::Tokens[42, 43].split_into_parts
    end
  end
  
  def test_encode
    assert_match(/\A\[\{(?:"type":"text"|"text":"string"|"kind":"type"|,){5}\},/, make_tokens.encode(:json))
  end
  
  def make_tokens
    tokens = CodeRay::Tokens.new
    assert_nothing_raised do
      tokens.text_token 'string', :type
      tokens.begin_group :operator
      tokens.text_token '()', :content
      tokens.end_group :operator
    end
    tokens
  end
  
end