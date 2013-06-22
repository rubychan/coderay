$: << '..'
require 'coderay'

tokens = CodeRay.scan File.read(__FILE__), :ruby
html = tokens.html(:tab_width => 2, :line_numbers => :inline, :line_number_start => -1)

puts html.page(:title => 'CodeRay HTML Encoder Example')

commment = <<_
This code must be > 10 lines
because I want to test the correct adjustment of the line numbers.
_
