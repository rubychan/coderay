require 'test/unit'
require 'coderay'

class JSONEncoderTest < Test::Unit::TestCase
  
  def test_json_output
    old_load_paths = $:.dup
    begin
      $:.delete '.'
      $:.delete File.dirname(__FILE__)
      json = CodeRay.scan('puts "Hello world!"', :ruby).json
      assert_equal [
        {"type"=>"text", "text"=>"puts", "kind"=>"ident"},
        {"type"=>"text", "text"=>" ", "kind"=>"space"},
        {"type"=>"block", "action"=>"open", "kind"=>"string"},
        {"type"=>"text", "text"=>"\"", "kind"=>"delimiter"},
        {"type"=>"text", "text"=>"Hello world!", "kind"=>"content"},
        {"type"=>"text", "text"=>"\"", "kind"=>"delimiter"},
        {"type"=>"block", "action"=>"close", "kind"=>"string"},
      ], JSON.load(json)
    ensure
      for path in old_load_paths - $:
        $: << path
      end
    end
  end
  
end