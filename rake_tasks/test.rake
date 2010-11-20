namespace :test do
  desc 'run all sample tests'
  task :samples do
    ruby "./sample/suite.rb"
  end
  
  desc 'run functional tests'
  task :functional do
    ENV['check_rubygems'] = 'true'
    ruby './test/functional/suite.rb'
    ruby './test/functional/for_redcloth.rb'
  end
  
  desc 'run all scanner tests'
  task :scanners do
    ruby "./test/scanners/suite.rb"
  end
  
  namespace :scanner do
    Dir['./test/scanners/*'].each do |scanner|
      next unless File.directory? scanner
      lang = File.basename(scanner)
      desc "run all scanner tests for #{lang}"
      task lang do
        ruby "./test/scanners/suite.rb #{lang}"
      end
    end
  end
  
  desc 'clean test output files'
  task :clean do
    for file in Dir['test/scanners/**/*.actual.*']
      rm file
    end
    for file in Dir['test/scanners/**/*.expected.html']
      rm file
    end
    for file in Dir['test/scanners/**/*.debug.diff*']
      rm file
    end
  end
  
end

task :test => %w( test:functional test:scanners )
task :samples => 'test:samples'