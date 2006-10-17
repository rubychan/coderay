require 'coderay'

SAMPLE = "puts 17 + 4\n"
puts 'Encoders Demo: ' + SAMPLE
scanner = CodeRay::Scanners[:ruby].new SAMPLE
encoder = CodeRay::Encoders[:statistic].new

tokens = scanner.tokenize
stats = encoder.encode_tokens tokens

puts
puts 'Statistic:'
puts stats

# alternative 1
tokens = CodeRay.scan SAMPLE, :ruby
encoder = CodeRay.encoder(:tokens)
textual = encoder.encode_tokens tokens
puts
puts 'Original text:'
puts textual

# alternative 2
yaml = CodeRay.encoder(:yaml).encode SAMPLE, :ruby
puts
puts 'YAML:'
puts yaml

# alternative 3
BIGSAMPLE = SAMPLE * 100
dump = CodeRay.scan(BIGSAMPLE, :ruby).dump
puts
puts 'Dump:'
p dump
puts 'compressed: %d byte < %d byte' % [dump.size, BIGSAMPLE.size]

puts
puts 'Undump:'
puts dump.undump.statistic
