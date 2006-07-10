class NitroHTMLTest < CodeRaySuite

  @file = __FILE__
  LANG = :xhtml
  EXTENSION = 'xhtml'

end

$suite << NitroHTMLTest.suite if $suite
