namespace :test do
  desc 'run all sample tests'
  task :samples do
    ruby "./sample/suite.rb"
  end
  
  desc 'run functional tests'
  task :functional do
    ruby "./test/functional/suite.rb"
  end
  
  namespace :functional do
    desc 'run all functional tests on all supported Ruby platforms'
    task :all do
      $stdout.sync = true
      for task in %w(test:functional 19 test:functional jruby test:functional ee test:functional)
        if task == 'test:functional'
          puts "\n\nTesting with #{RUBY}..."
          Rake::Task['test:functional'].reenable
          Rake::Task['test:functional'].invoke
        else
          Rake::Task[task].invoke
        end
      end
    end
  end
  
  desc 'run all scanner tests'
  task :scanners do
    ruby "./test/scanners/suite.rb"
  end
  
  desc 'clean test output files'
  task :clean do
    for file in Dir['test/scanners/**/*.actual.*']
      rm file
    end
  end
  
  desc 'run all tests on all supported Ruby platforms'
  task :all do
    $stdout.sync = true
    for task in %w(test 19 test jruby test)
      if task == 'test'
        puts "\n\nTesting with #{RUBY}..."
        Rake::Task['test'].reenable
        Rake::Task['test:functional'].reenable
        Rake::Task['test:scanners'].reenable
        Rake::Task['test'].invoke
      else
        Rake::Task[task].invoke
      end
    end
  end
  
end

task :test => %w( test:functional test:scanners )
task :samples => 'test:samples'
