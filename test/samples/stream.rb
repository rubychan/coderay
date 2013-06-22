require 'coderay'

code = File.read($0) * 500
puts "Size of code: %d KB" % [code.size / 1024]

puts "Use your system's memory tracker to see how much RAM this takes."
print 'Press some key to continue...'; gets

require 'benchmark'
e = CodeRay.encoder(:div)
for do_stream in [true, false]
	puts "Scanning and encoding in %s mode, please wait..." %
		[do_stream ? 'streaming' : 'normal']
	output = ''
	time = Benchmark.realtime do
		if do_stream
			output = e.encode_stream(code, :ruby)
		else
			output = e.encode_tokens(t = CodeRay.scan(code, :ruby))
		end
	end
	puts 'Finished after %4.2f seconds.' % time
	puts "Size of output: %d KB" % [output.size / 1024]
	print 'Press some key to continue...'; gets
end
