require 'coderay'

# scan some code
tokens = CodeRay.scan(File.read($0), :ruby)

# dump using YAML
yaml = tokens.yaml
puts 'YAML: %4d bytes' % yaml.size

# dump using Marshal
dump = tokens.dump(0)
puts 'Dump: %4d bytes' % dump.size

# undump and encode
puts 'undumped:', dump.undump.div(:css => :class)
