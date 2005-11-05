require 'coderay'

begin
	CodeRay::Encoders::YAML
rescue
	puts 'CodeRay::Encoders::YAML is not defined; you must load it first.'
end

yaml_encoder = CodeRay::Encoders[:yaml] 
print 'Now it is loaded: '
p yaml_encoder
puts 'See?'

tokens_encoder = require_plugin 'CodeRay::Encoders/tokens'
print 'Require is also possible: '
p tokens_encoder
puts 'See?'

puts 'Require all Encoders:'
CodeRay::Encoders.load_all
p CodeRay::Encoders.plugin_hash
