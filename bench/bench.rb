# The most ugly test script I've ever written!
# Shame on me!

require 'profile' if ARGV.include? '-p'
require 'coderay'

@size = ARGV.fetch(2, 100).to_i * 2**10  # 2**10 = 1 Ki

lang = ARGV.fetch(0) do
	puts <<-HELP
Usage:
  ruby bench.rb (c|ruby|dump) (null|text|tokens|count|statistic|yaml|html) [SIZE in KB] [stream]
  
	SIZE defaults to 100.
	SIZE = 0 means the whole input.
	SIZE is ignored when dump is input.
	
-p generates a profile (slow! use with SIZE = 1)
-o shows the output
stream enabled streaming mode

Sorry for the strange interface. I will improve it in the next release.
	HELP
	exit
end

format = ARGV.fetch(1, 'html').downcase

$stream = ARGV.include? 'stream'
$optimize = ARGV.include? 'opt'
$style = ARGV.include? 'style'

require 'benchmark'
require 'fileutils'

if format == 'comp'
	format = 'html'
	compare = true
	begin
		require 'syntax'
		require 'syntax/convertors/html.rb'
	rescue LoadError
		raise 'This requires Syntax! (Try % gem install syntax)'
	end
end

$dump_input = lang == 'dump'
$dump_output = format == 'dump'
require 'coderay/helpers/gzip_simple.rb' if $dump_input

MYDIR = File.dirname __FILE__
def here fn = nil
	return MYDIR unless fn	
	File.join here, fn
end

n = ARGV.find { |a| a[/^N/] }
N = if n then n[/\d+/].to_i else 1 end
o = ARGV.find { |a| a[/^O/] }
Offset = if o then o[/\d+/].to_i else 1 end
b = ARGV.find { |a| a[/^B/] }
BoldEvery = if b then b[/\d+/].to_i else 10 end
$filename = ARGV.include?('strange') ? 'strange' : 'example'

Benchmark.bm(20) do |bm|

	data = nil
	File.open(here("#$filename." + lang), 'rb') { |f| data = f.read }
	if $dump_input
		@size = CodeRay::Tokens.load(data).text_size
	else
		unless @size.zero?
			data += data until data.size >= @size
			data = data[0, @size]
		end
		@size = data.size
	end

	time = bm.report('CodeRay') do
		options = { :tab_width => 2, :line_numbers => :table, :line_numbers_offset => Offset, :bold_every => BoldEvery, :wrap => :page, :css => $style ? :style : :class}
		options[:debug] = $DEBUG
		$hl = CodeRay.encoder(format, options) unless $dump_output
		N.times do
			if $stream
				if $dump_input
					raise 'Can\'t stream dump.'
				elsif $dump_output
					raise 'Can\'t dump stream.'
				end
				$o = $hl.encode_stream(data, lang, options)
				@token_count = $hl.token_stream.size
			else
				if $dump_input
					tokens = CodeRay::Tokens.load data
				else
					tokens = CodeRay.scan(data, lang)
					@token_count = tokens.size
				end
				@token_count = tokens.size
				tokens.optimize! if $optimize
				if $dump_output
					$o = tokens.optimize.dump
				else
					$o = tokens.encode($hl)
				end
			end
		end 
		$file_created = 'test.' + format
		file = here($file_created)
		File.open(file, 'wb') do |f|
			f.write $o
		end
	end
	Dir.chdir(here) do
		FileUtils.copy 'test.dump', 'example.dump' if $dump_output
	end

	time_real = time.real / N

	puts "\t%7.2f KB/sec (%d.%d KB)\t%0.2f KTok/sec" % [((@size / 1024.0) / time_real), @size / 1024, @size % 1024, ((@token_count / 1000.0) / time_real)]
	puts $o if ARGV.include? '-o'

	if compare
		time = bm.report('Syntax') do
			c = Syntax::Convertors::HTML.for_syntax 'ruby'
			Dir.chdir(here) do
				File.open('test.syntax.' + format, 'wb') do |f|
					f.write '<html><head><style>%s</style></head><body><div class="ruby">%s</div></body></html>' % [DATA.read, c.convert(data)]
				end
			end
			$file_created << " and test.syntax.#{format}"
		end
		puts "\t%7.2f KB/sec" % ((@size / 1024.0) / time.real)
	end

end
puts "Files created: #$file_created"

STDIN.gets if ARGV.include? 'wait'

__END__
.ruby .normal {}
.ruby .comment { color: #005; font-style: italic; }
.ruby .keyword { color: #A00; font-weight: bold; }
.ruby .method { color: #077; }
.ruby .class { color: #074; }
.ruby .module { color: #050; }
.ruby .punct { color: #447; font-weight: bold; }
.ruby .symbol { color: #099; }
.ruby .string { color: #944; background: #FFE; }
.ruby .char { color: #F07; }
.ruby .ident { color: #004; }
.ruby .constant { color: #07F; }
.ruby .regex { color: #B66; background: #FEF; }
.ruby .number { color: #F99; }
.ruby .attribute { color: #7BB; }
.ruby .global { color: #7FB; }
.ruby .expr { color: #227; }
.ruby .escape { color: #277; }
