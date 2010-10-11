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

p Complex(3,4) == 3 + 4.im

puts 1.2 - 1.1 # => 0.0999999999999999

foo = /\p{Space}/
bar = /[[:space:]]/

def foo(first, *middle, last); end
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

# WoNáDos example
s.encode("utf-16BE", "utf-8", invalid: :replace, undef: :replace).encode("utf-8", "utf-16BE").delete("\uFFFD")
{
  and: 0, def: 0, end: 0, in: 0, or: 0, unless: 0, begin: 0, defined?: 0,
  ensure: 0, module: 0, redo: 0, super: 0, until: 0, BEGIN: 0, break: 0,
  do: 0, next: 0, rescue: 0, then: 0, when: 0, END: 0, case: 0, else: 0,
  for: 0, retry: 0, while: 0, alias: 0, class: 0, elsif: 0, if: 0, not: 0,
  return: 0, undef: 0, yield: 0,
  nil: 0, true: 0, false: 0, self: 0,
  DATA: 0, ARGV: 0, ARGF: 0, __FILE__: 0, __LINE__: 0, __ENCODING__: 0,
  foo!: 0, foo?: 0, Foo: 0, _: 0,
}
