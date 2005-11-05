class CTest < CodeRaySuite
	
	@file = __FILE__
	LANG = :c
	EXTENSION = 'c'
	
end

$suite << CTest.suite if $suite
