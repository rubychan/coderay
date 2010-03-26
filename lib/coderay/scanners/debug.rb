($:.unshift '../..'; require 'coderay') unless defined? CodeRay
module CodeRay
module Scanners

  # = Debug Scanner
  # 
  # Parses the output of the Encoders::Debug encoder.
  class Debug < Scanner

    include Streamable
    register_for :debug
    file_extension 'raydebug'
    title 'CodeRay Token Dump'
    
  protected
    
    def scan_tokens tokens, options

      opened_tokens = []

      until eos?

        kind = nil
        match = nil

          if scan(/\s+/)
            tokens << [matched, :space]
            next
            
          elsif scan(/ (\w+) \( ( [^\)\\]* ( \\. [^\)\\]* )* ) \) /x)
            kind = self[1].to_sym
            match = self[2].gsub(/\\(.)/, '\1')
            
          elsif scan(/ (\w+) ([<\[]) /x)
            kind = self[1].to_sym
            opened_tokens << kind
            case self[2]
            when '<'
              match = :open
            when '['
              match = :begin_line
            else
              raise
            end
            
          elsif !opened_tokens.empty? && scan(/ > /x)
            kind = opened_tokens.pop
            match = :close
            
          elsif !opened_tokens.empty? && scan(/ \] /x)
            kind = opened_tokens.pop
            match = :end_line
            
          else
            kind = :space
            getch

          end
                  
        match ||= matched
        if $CODERAY_DEBUG and not kind
          raise_inspect 'Error token %p in line %d' %
            [[match, kind], line], tokens
        end
        raise_inspect 'Empty token', tokens unless match

        tokens << [match, kind]
        
      end
      
      tokens
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
    [:open, :string],
    ['test', :content],
    [:close, :string],
    [:begin_line, :test],
    ["\n\n  \t   \n", :space],
    ["[]", :method],
    [:end_line, :test],
  ]
  
  def test_filtering_text_tokens
    assert_equal TEST_OUTPUT, CodeRay::Scanners::Debug.new.tokenize(TEST_INPUT)
    assert_equal TEST_OUTPUT, CodeRay.scan(TEST_INPUT, :debug)
  end
  
end
