require 'test/unit'
require 'coderay'

class DebugEncoderTest < Test::Unit::TestCase
  
  def test_creation
    debug = nil
    assert_nothing_raised do
      debug = CodeRay.encoder :debug
    end
    assert CodeRay::Encoders::Debug < CodeRay::Encoders::Encoder
    assert_kind_of CodeRay::Encoders::Encoder, debug
  end
  
  TEST_INPUT = CodeRay::Tokens[
    ['10', :integer],
    ['(\\)', :operator],
    [:begin_group, :string],
    ['test', :content],
    [:end_group, :string],
    [:begin_line, :head],
    ["\n", :space],
    ["\n  \t", :space],
    ["   \n", :space],
    ["[]", :method],
    [:end_line, :head],
  ].flatten
  TEST_OUTPUT = <<-'DEBUG'.chomp
integer(10)operator((\\\))string<content(test)>head[

  	   
method([])]
  DEBUG
  
  def test_filtering_text_tokens
    assert_equal TEST_OUTPUT, CodeRay::Encoders::Debug.new.encode_tokens(TEST_INPUT)
    assert_equal TEST_OUTPUT, TEST_INPUT.debug
  end
  
end

class DebugScannerTest < Test::Unit::TestCase
  
  def test_creation
    assert CodeRay::Scanners::Debug < CodeRay::Scanners::Scanner
    debug = nil
    assert_nothing_raised do
      debug = CodeRay.scanner :debug
    end
    assert_kind_of CodeRay::Scanners::Scanner, debug
  end
  
  TEST_INPUT = <<-'DEBUG'.chomp
integer(10)operator((\\\))string<content(test)>test[

  	   
method([])]
  DEBUG
  TEST_OUTPUT = CodeRay::Tokens[
    ['10', :integer],
    ['(\\)', :operator],
    [:begin_group, :string],
    ['test', :content],
    [:end_group, :string],
    [:begin_line, :unknown],
    ["\n\n  \t   \n", :space],
    ["[]", :method],
    [:end_line, :unknown],
  ].flatten
  
  def test_filtering_text_tokens
    assert_equal TEST_OUTPUT, CodeRay::Scanners::Debug.new.tokenize(TEST_INPUT)
    assert_kind_of CodeRay::TokensProxy, CodeRay.scan(TEST_INPUT, :debug)
    assert_equal TEST_OUTPUT, CodeRay.scan(TEST_INPUT, :debug).tokens
  end
  
end
