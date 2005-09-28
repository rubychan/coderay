require 'coderay'

data = File.read $0
page = CodeRay.scan(data, :ruby).optimize.html(:css => :style, :debug => $DEBUG).page

puts page
