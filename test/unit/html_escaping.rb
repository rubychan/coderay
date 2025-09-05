require 'test/unit'
require 'coderay'

class HtmlEscapingTest < Test::Unit::TestCase
  
  def test_begin_line_with_greater_than_in_attributes
    # Test that begin_line correctly handles '>' characters in HTML attributes
    # This addresses issue #263: Incomplete string escaping or encoding
    
    encoder = CodeRay::Encoders::HTML.new
    encoder.instance_variable_set(:@out, '')
    encoder.instance_variable_set(:@opened, [])
    encoder.instance_variable_set(:@span_for_kinds, {
      # Simulate a span with '>' characters in title attribute
      :test => '<span title="value > other" class="keyword">'
    })
    
    # Call begin_line which should add class="line" without breaking the title attribute
    encoder.send(:begin_line, :test)
    
    result = encoder.instance_variable_get(:@out)
    
    # The result should have class="line" added to the existing class attribute
    # and should NOT have corrupted the title attribute
    assert_equal '<span title="value > other" class="line keyword">', result
    assert result.include?('title="value > other"'), "Title attribute should remain intact"
    assert result.include?('class="line keyword"'), "Class should be properly updated"
  end
  
  def test_begin_line_without_existing_class
    # Test begin_line when the span doesn't have a class attribute
    
    encoder = CodeRay::Encoders::HTML.new
    encoder.instance_variable_set(:@out, '')
    encoder.instance_variable_set(:@opened, [])
    encoder.instance_variable_set(:@span_for_kinds, {
      # Span with '>' in attribute but no class
      :test => '<span title="a > b > c" data-info="x > y">'
    })
    
    encoder.send(:begin_line, :test)
    result = encoder.instance_variable_get(:@out)
    
    # Should add class="line" at the end, preserving all existing attributes
    assert_equal '<span title="a > b > c" data-info="x > y" class="line">', result
    assert result.include?('title="a > b > c"'), "Title attribute should remain intact"
    assert result.include?('data-info="x > y"'), "Data attribute should remain intact"
    assert result.include?('class="line"'), "Line class should be added"
  end
  
  def test_begin_line_normal_case
    # Test the normal case without special characters
    
    encoder = CodeRay::Encoders::HTML.new
    encoder.instance_variable_set(:@out, '')
    encoder.instance_variable_set(:@opened, [])
    encoder.instance_variable_set(:@span_for_kinds, {
      :test => '<span class="keyword">'
    })
    
    encoder.send(:begin_line, :test)
    result = encoder.instance_variable_get(:@out)
    
    assert_equal '<span class="line keyword">', result
  end
  
  def test_begin_line_no_style
    # Test when there's no predefined style for the kind
    
    encoder = CodeRay::Encoders::HTML.new
    encoder.instance_variable_set(:@out, '')
    encoder.instance_variable_set(:@opened, [])
    encoder.instance_variable_set(:@span_for_kinds, {})
    
    encoder.send(:begin_line, :unknown_kind)
    result = encoder.instance_variable_get(:@out)
    
    assert_equal '<span class="line">', result
  end
end