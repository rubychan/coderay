desc 'Do a benchmark'
task :benchmark do
  ruby "-v"
  ruby "-wIlib bench/bench.rb ruby div 1000 N5"
end

task :bench => :benchmark
