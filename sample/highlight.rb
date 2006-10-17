require 'coderay'

puts CodeRay.highlight('puts "Hello, World!"', :ruby)

output = CodeRay.highlight_file($0, :line_numbers => :table)
puts <<HTML
<html>
<head>
#{output.stylesheet true}
<body>
#{output}
</body>
</html>
HTML
