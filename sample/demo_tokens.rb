require 'coderay'

puts CodeRay.scan("puts 3 + 4, '3 + 4'", :ruby).tokens
