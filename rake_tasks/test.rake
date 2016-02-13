namespace :test do
  desc 'run functional tests'
  task :functional do
    ruby './test/functional/suite.rb'
    ruby './test/functional/for_redcloth.rb'
  end
  
  desc 'run unit tests'
  task :units do
    ruby './test/unit/suite.rb'
  end
  
  scanner_suite = 'test/scanners/suite.rb'
  desc 'run all scanner tests'
  task :scanners => :update_scanner_suite do
    ruby scanner_suite
  end
  
  desc 'update scanner test suite from GitHub'
  task :update_scanner_suite do
    if File.exist? scanner_suite
      Dir.chdir File.dirname(scanner_suite) do
        if File.directory? '.git'
          puts 'Updating scanner test suite...'
          sh 'git pull'
        elsif File.directory? '.svn'
          raise <<-ERROR
Found the deprecated Subversion scanner test suite in ./#{File.dirname(scanner_suite)}.
Please rename or remove it and run again to use the GitHub repository:

  mv test/scanners test/scanners-old
          ERROR
        else
          raise 'No scanner test suite found.'
        end
      end
    else
      puts 'Downloading scanner test suite...'
      sh 'git clone https://github.com/rubychan/coderay-scanner-tests.git test/scanners/'
    end
  end
  
  namespace :scanner do
    Dir['./test/scanners/*'].each do |scanner|
      next unless File.directory? scanner
      lang = File.basename(scanner)
      desc "run all scanner tests for #{lang}"
      task lang => :update_scanner_suite do
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
