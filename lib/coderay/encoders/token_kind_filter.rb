($:.unshift '../..'; require 'coderay') unless defined? CodeRay
module CodeRay
module Encoders
  
  load :filter
  
  # A Filter that selects tokens based on their token kind.
  # 
  # == Options
  # 
  # === :exclude
  # 
  # One or many symbols (in an Array) which shall be excluded.
  # 
  # Default: []
  # 
  # === :include
  # 
  # One or many symbols (in an array) which shall be included.
  # 
  # Default: :all, which means all tokens are included.
  # 
  # Exclusion wins over inclusion.
  # 
  # See also: CommentFilter
  class TokenKindFilter < Filter
    
    register_for :token_kind_filter
    
    DEFAULT_OPTIONS = {
      :exclude => [],
      :include => :all
    }
    
  protected
    def setup options
      super
      @group_excluded = false
      @exclude = options[:exclude]
      @exclude = Array(@exclude) unless @exclude == :all
      @include = options[:include]
      @include = Array(@include) unless @include == :all
    end
    
    def include_text_token? text, kind
      include_group? kind
    end
    
    def include_group? kind
       (@include == :all || @include.include?(kind)) &&
      !(@exclude == :all || @exclude.include?(kind))
    end
    
  public
    
    # Add the token to the output stream if +kind+ matches the conditions.
    def text_token text, kind
      super if !@group_excluded && include_text_token?(text, kind)
    end
    
    # Add the token group to the output stream if +kind+ matches the
    # conditions.
    # 
    # If it does not, all tokens inside the group are excluded from the
    # stream, even if their kinds match.
    def begin_group kind
      if @group_excluded
        @group_excluded += 1
      elsif include_group? kind
        super
      else
        @group_excluded = 1
      end
    end
    
    # See +begin_group+.
    def begin_line kind
      if @group_excluded
        @group_excluded += 1
      elsif include_group? kind
        super
      else
        @group_excluded = 1
      end
    end
    
    # Take care of re-enabling the delegation of tokens to the output stream
    # if an exluded group has ended.
    def end_group kind
      if @group_excluded
        @group_excluded -= 1
        @group_excluded = false if @group_excluded.zero?
      else
        super
      end
    end
    
    # See +end_group+.
    def end_line kind
      if @group_excluded
        @group_excluded -= 1
        @group_excluded = false if @group_excluded.zero?
      else
        super
      end
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
