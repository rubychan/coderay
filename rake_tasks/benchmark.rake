desc 'Do a benchmark'
task :benchmark do
  system "#{RUBY} -wIlib bench/bench.rb ruby div 1000"
end

task :bench => :benchmark
