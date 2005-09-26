require 'coderay'

begin
	CodeRay::Encoders::YAML
rescue
	puts 'CodeRay::Encoders::YAML is not defined; you must load it first.'
end

yaml_encoder = CodeRay::Encoders[:yaml] 
puts 'Now it is loaded.'

p yaml_encoder == CodeRay::Encoders::YAML  #-> true
puts 'See?'
