$: << '..'
require 'coderay'

e = CodeRay.encoder(:html)
t = e.encode_stream('a LOT of :code', :ruby)

puts t
p t.class
