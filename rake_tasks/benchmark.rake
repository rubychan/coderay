desc 'Do a benchmark'
task :benchmark do
  ruby 'bench/bench.rb ruby html'
end

task :bench => :benchmark
