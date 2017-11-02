require 'benchmark'
$: << File.expand_path('../../lib', __FILE__)
require 'coderay'

if ARGV.include? '-h'
  puts DATA.read
  exit
end

lang = ARGV.fetch(0, 'ruby')
data = nil
File.open(File.expand_path("../example.#{lang}", __FILE__), 'rb') { |f| data = f.read }
raise 'Example file is empty.' if data.empty?

format = ARGV.fetch(1, 'html').downcase
encoder = CodeRay.encoder(format)

size = ARGV.fetch(2, 3000).to_i * 1000
unless size.zero?
  data += data until data.size >= size
  data = data[0, size]
end
size = data.size
puts "encoding %d kB of #{lang} code to #{format}..." % [(size / 1000.0).round]

n = ARGV.fetch(3, 10).to_s[/\d+/].to_i
require 'profile' if ARGV.include? '-p'
times = []
n.times do |i|
  time = Benchmark.realtime { encoder.encode(data, lang) }
  puts "run %d: %5.2f s, %4.0f kB/s" % [i + 1, time, size / time / 1000.0]
  times << time
end

times_sum = times.inject(0) { |time, sum| sum + time }
puts 'Average time: %5.2f s, %4.0f kB/s' % [times_sum / times.size, (size * n) / times_sum / 1000.0]
puts 'Best time:    %5.2f s, %4.0f kB/s' % [times.min, size / times.min / 1000.0]

__END__
Usage:
  ruby bench.rb [lang] [format] [size in kB] [number of runs]

  - lang defaults to ruby.
  - format defaults to html.
  - size defaults to 1000 kB (= 1,000,000 bytes). 0 uses the whole example input.
  - number of runs defaults to 5.

-h prints this help
-p generates a profile (slow, use with SIZE = 1)
-w waits after the benchmark (for debugging memory usw)
