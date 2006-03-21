require 'coderay'
require 'benchmark'

N = 10
$code = 'foo(Foo[:foo, /foo/m]); ' * 500
Benchmark.bm 15 do |bm|
	bm.report 'loading' do
		CodeRay::Scanners.load :ruby
		CodeRay::Encoders.load :div
	end
	bm.report 'CodeRay.encode' do N.times do
		CodeRay.encode($code, :ruby, :div)
	end end
	bm.report 'Direct' do N.times do
		CodeRay::Encoders::Div.new.encode_tokens(
			CodeRay::Scanners::Ruby.new($code).tokenize
		)
	end end
	bm.report 'Semi-cached' do
		encoder = CodeRay::Encoders::Div.new
		N.times do
			encoder.encode $code, :ruby
		end
	end
	bm.report 'Fully cached' do
		scanner = CodeRay::Scanners::Ruby.new('')
		encoder = CodeRay::Encoders::Div.new
		N.times do
			scanner.string = $code
			encoder.encode_tokens scanner.tokens
		end
	end
	bm.report 'Duo cached' do
		duo = CodeRay::Duo[:ruby, :div]
		N.times do
			duo.encode $code
		end
	end
end
