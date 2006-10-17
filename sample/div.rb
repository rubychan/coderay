require 'coderay'

puts CodeRay.scan(DATA.read, :ruby).div

__END__
for a in 0..255
	a = a.chr
	begin
		x = eval("?\\#{a}")
		if x == a[0]
			next
		else
			print "#{a}: #{x}"
		end
	rescue SyntaxError => boom
		print "#{a}: error"
	end
	puts
end
