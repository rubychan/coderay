
# Load CodeRay
# If this doesn't work, try ruby -rubygems.
require 'coderay'

# Generate HTML page for Ruby code.
page = CodeRay.scan("puts 'Hello, world!'", :ruby).span

# Print it
puts page
