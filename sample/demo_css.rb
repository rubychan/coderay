require 'coderay'

# print the default stylesheet for HTML codes
puts CodeRay::Encoders[:html]::CSS.new.stylesheet
