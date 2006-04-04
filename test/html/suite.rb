class HTMLTest < CodeRaySuite
	
	@file = __FILE__
	LANG = :html
	EXTENSION = 'html'
	
end

$suite << HTMLTest.suite if $suite
