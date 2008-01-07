require 'test/unit'
require 'coderay'

class TC_Latex_Encoder < Test::Unit::TestCase
  def setup
    CodeRay::Encoders.plugin_path 'lib/coderay/encoders'
    @enc = CodeRay::Encoders[:latex].new
  end


  def test_simple
    source_text = <<EOD
function update_stars(num)
{
  for (var i = 0; i < 10; ++i) {
    var star = $("star"+(i+1));
    if (i < num) {
      if (! star.visible()) {
        Effect.Appear(star);
      }
    } else {
      if (star.visible()) {
        Effect.Fade(star);
      }
    }
  }
}
EOD
    expected = [["function", :reserved],[" ", :space],["update_stars", :ident],
                ["(", :operator], ["num", :ident], [")", :operator],
                ["\n", :space],
                ["{", :operator],
                ["\n  ", :space],
                ["for", :reserved], [" ", :space],
                  ["(", :operator], ["var", :reserved], [" ", :space],
                  ["i", :ident],[" ", :space], ["=", :operator], [" ", :space],
                  ["0", :integer],
                  [";", :operator],
                  [" ", :space], ["i", :ident], [" ", :space],
                  ["<", :operator], [" ", :space], ["10", :integer],
                  [";", :operator],
                  [" ", :space], ["++", :operator], ["i", :ident],
                  [")", :operator], [" ", :space], ["{", :operator],
                ["\n    ", :space],
                ["var", :reserved], [" ", :space], ["star", :ident],
                [" ", :space], ["=", :operator], [" ", :space],
                ["$", :ident], ["(", :operator],
                  [:open, :string], ["\"", :delimiter], ["star", :content],
                  ["\"", :delimiter], [:close, :string],
                  ["+", :operator],
                  ["(", :operator], ["i", :ident], ["+", :operator],
                  ["1", :integer], [")", :operator],
                [")", :operator],
                [";", :operator],
                ["\n    ", :space],
                ["if", :reserved], [" ", :space],
                  ["(", :operator], ["i", :ident], [" ", :space],
                  ["<", :operator], [" ", :space], ["num", :ident],
                  [")", :operator], [" ", :space], ["{", :operator],
                ["\n      ", :space],
                ["if", :reserved], [" ", :space],
                  ["(", :operator], ["!", :operator], [" ", :space],
                  ["star", :ident], [".", :operator], ["visible", :ident],
                  ["(", :operator], [")", :operator], [")", :operator],
                [" ", :space],
                ["{", :operator],
                ["\n        ", :space],
                ["Effect", :ident], [".", :operator], ["Appear", :ident],
                  ["(", :operator], ["star", :ident], [")", :operator],
                  [";", :operator], ["\n      ", :space],
                ["}", :operator],
                ["\n    ", :space],
                ["}", :operator],
                [" ", :space], ["else", :reserved], [" ", :space],
                ["{", :operator],
                ["\n      ", :space],
                ["if", :reserved], [" ", :space],
                  ["(", :operator], ["star", :ident], [".", :operator],
                  ["visible", :ident], ["(", :operator], [")", :operator],
                  [")", :operator],
                [" ", :space],
                ["{", :operator],
                ["\n        ", :space],
                ["Effect", :ident], [".", :operator], ["Fade", :ident],
                  ["(", :operator], ["star", :ident], [")", :operator],
                  [";", :operator],
                ["\n      ", :space],
                ["}", :operator],
                ["\n    ", :space],
                ["}", :operator],
                ["\n  ", :space],
                ["}", :operator],
                ["\n", :space],
                ["}", :operator],
                ["\n", :space]]
    symbol_list = CodeRay.scan(source_text, :javascript)
    assert_equal(expected, symbol_list)
  end


  def teardown
    @enc = nil
  end
end
