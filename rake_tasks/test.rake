namespace :test do
  
  desc 'run all sample tests'
  task :samples do
    ruby './sample/suite.rb'
  end
  
  desc 'run functional tests'
  task :functional do
    ENV['check_rubygems'] = 'true'
    ruby './test/functional/suite.rb'
    ruby './test/functional/for_redcloth.rb'
  end
  
  desc 'run unit tests'
  task :units do
    ENV['check_rubygems'] = 'true'
    ruby './test/unit/suite.rb'
  end
  
  scanner_suite = './test/scanners/suite.rb'
  task scanner_suite do
    puts 'Scanner tests not found; downloading from Subversion...'
    sh 'svn co http://svn.rubychan.de/coderay-scanner-tests/trunk/ test/scanners/'
    puts 'Finished.'
  end
  
  desc 'run all scanner tests'
  task :scanners => scanner_suite do
    ruby scanner_suite
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
    for file in Dir['test/scanners/**/*.debug.diff']
      rm file
    end
    for file in Dir['test/scanners/**/*.debug.diff.html']
      rm file
    end
    for file in Dir['test/scanners/**/*.expected.html']
      rm file
    end
  end
  
  desc 'test the CodeRay executable'
  task :exe do
    if RUBY_VERSION >= '1.8.7'
      ruby './test/executable/suite.rb'
    else
      puts
      puts "Can't run executable tests because shoulda-context requires Ruby 1.8.7+."
      puts "Skipping."
    end
  end
  
end

task :test => %w(test:functional test:units test:exe)
task :samples => 'test:samples'