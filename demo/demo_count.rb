require 'coderay'

stats = CodeRay.encoder(:statistic)
stats.encode("puts 17 + 4\n", :ruby)

puts '%d out of %d tokens have the kind :integer.' % [
	stats.type_stats[:integer].count,
	stats.real_token_count
]
#-> 2 out of 4 tokens have the kind :integer.
