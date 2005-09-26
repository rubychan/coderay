require 'coderay'
require 'erb'
include ERB::Util

code = <<'CODE'
$ie.text_field(:name, "pAnfrage ohne $gV und mit #{$gv}").set artikel
oder
text = $bla.test(...) 
CODE
puts <<HTML
<html>
<head>
<style>span.glob-var { color: green; font-weight: bold; }</style>
</head>
<body>
HTML

CodeRay.scan_stream code, :ruby do |text, kind|
	next if text.is_a? Symbol
	text = h(text)
	text = '<span class="glob-var">%s</span>' % text if kind == :global_variable
	print text
end

puts <<HTML
</body>
</html>
HTML
