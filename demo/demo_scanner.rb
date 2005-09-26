require 'coderay'
c_scanner = CodeRay::Scanners[:c].new "if (*p == '{') nest++;"
for text, kind in c_scanner
	print text if kind == :operator
end
puts

ruby_scanner = CodeRay::Scanners[:ruby].new %q<c_scanner = CodeRay::Scanners[:c].new "if (*p == '{') nest++;">

puts ruby_scanner.any? { |text, kind| kind == :string and text == :open}
puts ruby_scanner.find { |text, kind| kind == :regexp }
puts ruby_scanner.map { |text, kind| text if kind != :space }.compact.join(' ')
