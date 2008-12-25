desc 'Do a benchmark'
task :benchmark do
  ruby "-v"
  ruby "-Ilib bench/bench.rb ruby div 1000"
end

task :bench => :benchmark
