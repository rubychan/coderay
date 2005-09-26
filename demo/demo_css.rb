require 'coderay'

data = File.read 'L:\bench\strange.ruby'
page = CodeRay.scan(data, :ruby).optimize.html(:css => :style, :debug => $DEBUG).page

puts page
