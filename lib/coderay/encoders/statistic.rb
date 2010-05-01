($:.unshift '../..'; require 'coderay') unless defined? CodeRay
module CodeRay
module Encoders

  # Makes a statistic for the given tokens.
  # 
  # Alias: +stats+
  class Statistic < Encoder

    include Streamable
    register_for :stats, :statistic

    attr_reader :type_stats, :real_token_count  # :nodoc:

    TypeStats = Struct.new :count, :size  # :nodoc:

  protected

    def setup options
      @type_stats = Hash.new { |h, k| h[k] = TypeStats.new 0, 0 }
      @real_token_count = 0
    end

    def generate tokens, options
      @tokens = tokens
      super
    end

    def text_token text, kind
      @real_token_count += 1 unless kind == :space
      @type_stats[kind].count += 1
      @type_stats[kind].size += text.size
      @type_stats['TOTAL'].size += text.size
      @type_stats['TOTAL'].count += 1
    end

    # TODO Hierarchy handling
    def begin_group kind
      block_token 'begin_group'
    end

    def end_group kind
      block_token 'end_group'
    end

    def begin_line kind
      block_token 'begin_line'
    end

    def end_line kind
      block_token 'end_line'
    end
    
    def block_token action
      @type_stats['TOTAL'].count += 1
      @type_stats[action].count += 1
    end

    STATS = <<-STATS  # :nodoc:

Code Statistics

Tokens            %8d
  Non-Whitespace  %8d
Bytes Total       %8d

Token Types (%d):
  type                     count     ratio    size (average)
-------------------------------------------------------------
%s
      STATS
# space                    12007   33.81 %     1.7
    TOKEN_TYPES_ROW = <<-TKR  # :nodoc:
  %-20s  %8d  %6.2f %%   %5.1f
      TKR

    def finish options
      all = @type_stats['TOTAL']
      all_count, all_size = all.count, all.size
      @type_stats.each do |type, stat|
        stat.size /= stat.count.to_f
      end
      types_stats = @type_stats.sort_by { |k, v| [-v.count, k.to_s] }.map do |k, v|
        TOKEN_TYPES_ROW % [k, v.count, 100.0 * v.count / all_count, v.size]
      end.join
      STATS % [
        all_count, @real_token_count, all_size,
        @type_stats.delete_if { |k, v| k.is_a? String }.size,
        types_stats
      ]
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

Token Types (5):
  type                     count     ratio    size (average)
-------------------------------------------------------------
  TOTAL                       11  100.00 %     1.8
  space                        3   27.27 %     3.0
  begin_group                  1    9.09 %     0.0
  begin_line                   1    9.09 %     0.0
  content                      1    9.09 %     4.0
  end_group                    1    9.09 %     0.0
  end_line                     1    9.09 %     0.0
  integer                      1    9.09 %     2.0
  method                       1    9.09 %     2.0
  operator                     1    9.09 %     3.0

  DEBUG
  
  def test_filtering_text_tokens
    assert_equal TEST_OUTPUT, CodeRay::Encoders::Statistic.new.encode_tokens(TEST_INPUT)
    assert_equal TEST_OUTPUT, TEST_INPUT.statistic
  end
  
end