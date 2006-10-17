namespace :test do
  desc 'Test CodeRay Demos'
  task :samples do
    system 'ruby -wd ./sample/suite.rb'
  end
  
  desc 'Test CodeRay'
  task :scanners do
    system 'ruby -wd ./test/scanners/suite.rb'
  end
  
  desc 'Clean test output files'
  task :clean do
    for file in Dir['test/scanners/**/*.actual.*']
      rm file
    end
  end
end

task :test => %w( test:scanners )
task :samples => 'test:samples'
