require 'coderay'

# scan this file
tokens = CodeRay.scan(File.read($0) * 1, :ruby)

# output it with two styles of line numbers
out = tokens.div(:line_numbers => :table)
out << '<hr />'
out << tokens.div(:line_numbers => :inline, :line_number_start => 8)

puts out.page(:title => 'CodeRay HTML Encoder Example')
