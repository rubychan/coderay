require 'coderay'

p CodeRay.scan("puts 3 + 4, '3 + 4'", :ruby)
