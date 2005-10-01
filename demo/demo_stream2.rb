require 'coderay'

token_stream = CodeRay::TokenStream.new do |kind, text|
  puts 'kind: %s, text size: %d.' % [kind, text.size]
end

token_stream << [:regexp, '/\d+/'] << [:space, "\n"]
#-> kind: rexpexp, text size: 5.
