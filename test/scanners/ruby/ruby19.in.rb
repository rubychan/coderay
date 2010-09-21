block.(*arguments)  # bovi's example

def (foo).bar
end

# from http://slideshow.rubyforge.org/ruby19.html#34

{ a: b }
redirect_to action: show
{:a => b}
redirect_to :action => show

[1,2].each {|value; t| t=value*value}

[1,2].inject(:+)
[1,2].inject {|a,b| a+b}

short_enum = [1, 2, 3].to_enum
long_enum = ('a'..'z').to_enum
loop do
  puts "#{short_enum.next} #{long_enum.next}"
end

e = [1,2,3].each

p = -> a,b,c {a+b+c}
puts p.(1,2,3)
puts p[1,2,3]
p = lambda {|a,b,c| a+b+c}
puts p.call(1,2,3)

Complex(3,4) == 3 + 4.im

irb(main):001:0> 1.2-1.1
=> 0.0999999999999999

/\p{Space}/
/[:space:]/

def foo(first, *middle, last)
(->a, *b, c {p a-c}).(*5.downto(1))

f = Fiber.new do
  a,b = 0,1
  Fiber.yield a
  Fiber.yield b
  loop do
    a,b = b,a+b
    Fiber.yield b
  end
end
10.times {puts f.resume}

match =
   while line = gets
     next if line =~ /^#/
     break line if line.find('ruby')
   end

def toggle
  def toggle
    "subsequent times"
  end
  "first time"
end
