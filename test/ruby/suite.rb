class RubyTest < CodeRaySuite
	
	@file = __FILE__
	LANG = :ruby
	EXTENSION = 'rb'
	
end

$suite << RubyTest.suite if $suite
