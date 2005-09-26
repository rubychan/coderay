require 'coderay'

puts CodeRay.
	scan("puts 'Hello, world!'", :ruby).
	compact.
	dump.
	undump.
	html(:wrap => :div)
