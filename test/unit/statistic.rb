require 'test/unit'
require 'coderay'

class StatisticEncoderTest < Test::Unit::TestCase
  
  def test_creation
    assert CodeRay::Encoders::Statistic < CodeRay::Encoders::Encoder
    stats = nil
    assert_nothing_raised do
      stats = CodeRay.encoder :statistic
    end
    assert_kind_of CodeRay::Encoders::Encoder, stats
  end
  
  TEST_INPUT = CodeRay::Tokens[
    ['10', :integer],
    ['(\\)', :operator],
    [:begin_group, :string],
    ['test', :content],
    [:end_group, :string],
    [:begin_line, :test],
    ["\n", :space],
    ["\n  \t", :space],
    ["   \n", :space],
    ["[]", :method],
    [:end_line, :test],
  ].flatten
  TEST_OUTPUT = <<-'DEBUG'

Code Statistics

Tokens                  11
  Non-Whitespace         4
Bytes Total             20

Token Types (7):
  type                     count     ratio    size (average)
-------------------------------------------------------------
  TOTAL                       11  100.00 %     1.8
  space                        3   27.27 %     3.0
  string                       2   18.18 %     0.0
  test                         2   18.18 %     0.0
  :begin_group                 1    9.09 %     0.0
  :begin_line                  1    9.09 %     0.0
  :end_group                   1    9.09 %     0.0
  :end_line                    1    9.09 %     0.0
  content                      1    9.09 %     4.0
  integer                      1    9.09 %     2.0
  method                       1    9.09 %     2.0
  operator                     1    9.09 %     3.0

  DEBUG
  
  def test_filtering_text_tokens
    assert_equal TEST_OUTPUT, CodeRay::Encoders::Statistic.new.encode_tokens(TEST_INPUT)
    assert_equal TEST_OUTPUT, TEST_INPUT.statistic
  end
  
end