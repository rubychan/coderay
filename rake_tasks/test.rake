namespace :test do
  desc 'run all sample tests'
  task :samples do
    system 'ruby -w ./sample/suite.rb'
  end
  
  desc 'run functional tests'
  task :functional do
    system 'ruby -w ./test/functional/suite.rb'
  end
  
  desc 'run all scanner tests'
  task :scanners do
    system 'ruby -w ./test/scanners/suite.rb'
  end
  
  desc 'clean test output files'
  task :clean do
    for file in Dir['test/scanners/**/*.actual.*']
      rm file
    end
  end
end

task :test => %w( test:functional test:scanners )
task :samples => 'test:samples'
