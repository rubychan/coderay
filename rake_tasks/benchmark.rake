desc 'Do a benchmark'
task :benchmark do
  ruby 'bench/bench.rb ruby html 3000'
end

task :bench => :benchmark
