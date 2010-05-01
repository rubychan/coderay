($:.unshift '../..'; require 'coderay') unless defined? CodeRay
module CodeRay
module Encoders

  # = Debug Encoder
  #
  # Fast encoder producing simple debug output.
  #
  # It is readable and diff-able and is used for testing.
  #
  # You cannot fully restore the tokens information from the
  # output, because consecutive :space tokens are merged.
  # Use Tokens#dump for caching purposes.
  # 
  # See also: Scanners::Debug
  class Debug < Encoder

    include Streamable
    register_for :debug

    FILE_EXTENSION = 'raydebug'
    
    def initialize options = {}
      super
      @opened = []
    end

  public
  
    def text_token text, kind
      if kind == :space
        @out << text
      else
        text = text.gsub(/[)\\]/, '\\\\\0')  # escape ) and \
        @out << kind.to_s << '(' << text << ')'
      end
    end

    def begin_group kind
      @opened << kind
      @out << kind.to_s << '<'
    end

    def end_group kind
      if @opened.last != kind
        puts @out
        raise "we are inside #{@opened.inspect}, not #{kind}"
      end
      @opened.pop
      @out << '>'
    end

    def begin_line kind
      @out << kind.to_s << '['
    end

    def end_line kind
      @out << ']'
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

class DebugEncoderTest < Test::Unit::TestCase
  
  def test_creation
    assert CodeRay::Encoders::Debug < CodeRay::Encoders::Encoder
    debug = nil
    assert_nothing_raised do
      debug = CodeRay.encoder :debug
    end
    assert_kind_of CodeRay::Encoders::Encoder, debug
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
  TEST_OUTPUT = <<-'DEBUG'.chomp
integer(10)operator((\\\))string<content(test)>test[

  	   
method([])]
  DEBUG
  
  def test_filtering_text_tokens
    assert_equal TEST_OUTPUT, CodeRay::Encoders::Debug.new.encode_tokens(TEST_INPUT)
    assert_equal TEST_OUTPUT, TEST_INPUT.debug
  end
  
end
