require 'coderay'

c_code = "if (*p == '{') nest++;"
puts 'C Code: ' + c_code
puts

c_scanner = CodeRay::Scanners[:c].new c_code

puts '> print only operators:'
for text, kind in c_scanner
	print text if kind == :operator
end
puts
puts '-' * 30
puts

ruby_code = %q!ruby_code(:can, BE, %r[q[ui]te #{ /comple/x },] => $-s, &?\xee)!
puts 'Ruby Code: ' + ruby_code
puts

ruby_scanner = CodeRay::Scanners[:ruby].new ruby_code

puts '> has a string?'
puts ruby_scanner.
	any? { |text, kind| kind == :string }
puts

puts '> number of regexps?'
puts ruby_scanner.
	select { |token| token == [:open, :regexp] }.size
puts

puts '> has a string?'
puts ruby_scanner.
	reject { |text, kind| not text.is_a? String }.
	map { |text, kind| %("#{text}" (#{kind})) }.join(', ')
