class XMLTest < CodeRaySuite

  @file = __FILE__
  LANG = :xml
  EXTENSION = 'xml'

end

$suite << XMLTest.suite if $suite
