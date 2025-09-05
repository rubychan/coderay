require 'test/unit'
require 'coderay'

class HtmlCommentFilteringTest < Test::Unit::TestCase
  
  def test_html_comment_filtering_consistency
    # Test case based on issue #262
    # Comments with extra characters after --> should be handled consistently
    
    # Normal comment ending with -->
    html_normal_comment = <<-HTML
<script>
  <!-- This is a normal comment -->
  alert('test');
</script>
HTML
    
    # Comment ending with -->!> (extra characters after comment end)
    html_comment_with_extra = <<-HTML
<script>
  <!-- This is a comment -->!>
  alert('test');
</script>
HTML
    
    tokens_normal = CodeRay.scan(html_normal_comment, :html)
    tokens_extra = CodeRay.scan(html_comment_with_extra, :html)
    
    html_normal = tokens_normal.html
    html_extra = tokens_extra.html
    
    # Both comments should be properly tokenized without error tokens
    # The normal comment should end with -->
    assert html_normal.include?('--&gt;</span>'), "Normal comment should end with -->"
    assert !html_normal.include?('error'), "Normal comment should not contain error tokens"
    
    # The comment with extra chars should end with -->!> and not have separate error tokens
    assert html_extra.include?('--&gt;!&gt;</span>'), "Comment with extra chars should end with -->!>"
    assert !html_extra.include?('error'), "Comment with extra chars should not contain error tokens"
    
    # Both should have the same basic structure: comment opening, inline content, comment closing
    assert html_normal.include?('<span class="comment">  &lt;!--</span>'), "Normal comment should have proper opening"
    assert html_extra.include?('<span class="comment">  &lt;!--</span>'), "Extra comment should have proper opening"
    
    assert html_normal.include?('<span class="inline">'), "Normal comment should have inline content"
    assert html_extra.include?('<span class="inline">'), "Extra comment should have inline content"
  end
  
end