require 'coderay'
require 'coderay/encoders/html'

puts CodeRay["puts CodeRay['...', :ruby]", :ruby].div
