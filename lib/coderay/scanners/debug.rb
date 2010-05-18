($:.unshift '../..'; require 'coderay') unless defined? CodeRay
module CodeRay
module Scanners

  # = Debug Scanner
  # 
  # Interprets the output of the Encoders::Debug encoder.
  class Debug < Scanner

    register_for :debug
    title 'CodeRay Token Dump Import'
    
  protected
    
    def scan_tokens encoder, options

      opened_tokens = []

      until eos?

        if match = scan(/\s+/)
          encoder.text_token match, :space
          
        elsif match = scan(/ (\w+) \( ( [^\)\\]* ( \\. [^\)\\]* )* ) \)? /x)
          kind = self[1].to_sym
          match = self[2].gsub(/\\(.)/, '\1')
          unless Tokens::AbbreviationForKind.has_key? kind
            kind = :error
            match = matched
          end
          encoder.text_token match, kind
          
        elsif match = scan(/ (\w+) ([<\[]) /x)
          kind = self[1].to_sym
          opened_tokens << kind
          case self[2]
          when '<'
            encoder.begin_group kind
          when '['
            encoder.begin_line kind
          else
            raise 'CodeRay bug: This case should not be reached.'
          end
          
        elsif !opened_tokens.empty? && match = scan(/ > /x)
          encoder.end_group opened_tokens.pop
          
        elsif !opened_tokens.empty? && match = scan(/ \] /x)
          encoder.end_line opened_tokens.pop
          
        else
          encoder.text_token getch, :space
          
        end
        
      end
      
      encoder.end_group opened_tokens.pop until opened_tokens.empty?
      
      encoder
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
    [:begin_group, :string],
    ['test', :content],
    [:end_group, :string],
    [:begin_line, :test],
    ["\n\n  \t   \n", :space],
    ["[]", :method],
    [:end_line, :test],
  ].flatten
  
  def test_filtering_text_tokens
    assert_equal TEST_OUTPUT, CodeRay::Scanners::Debug.new.tokenize(TEST_INPUT)
    assert_equal TEST_OUTPUT, CodeRay.scan(TEST_INPUT, :debug)
  end
  
end
