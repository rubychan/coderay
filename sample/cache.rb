require 'coderay'

html_encoder = CodeRay.encoder :html

scanner = Hash.new do |h, lang|
	h[lang] = CodeRay.scanner lang
end

for lang in [:ruby, :html]
	tokens = scanner[lang].tokenize 'test <test>'
	puts html_encoder.encode_tokens(tokens)
end
