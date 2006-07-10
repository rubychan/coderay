desc 'Do a benchmark'
task :benchmark do
  system 'ruby -wIlib bench\bench.rb ruby html 0'
end

task :bench => :benchmark
