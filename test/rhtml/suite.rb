class RHTMLTest < CodeRaySuite

  @file = __FILE__
  LANG = :rhtml
  EXTENSION = 'rhtml'

end

$suite << RHTMLTest.suite if $suite
