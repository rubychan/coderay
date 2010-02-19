require 'rake/gempackagetask.rb'

def gemspec
  Gem::Specification.new do |s|
    # Basic Information
    # s.name will be set later
    s.rubyforge_project = 'coderay'
    s.version = '0'

    s.platform = Gem::Platform::RUBY
    s.required_ruby_version = '>= 1.8.2'
    s.requirements = []
    s.date = Time.now.strftime '%Y-%m-%d'
    s.has_rdoc = true
    s.rdoc_options = '-SNw2', '-mlib/README', '-a', '-t CodeRay Documentation'
    s.extra_rdoc_files = EXTRA_FILES.in('./')

    # Description
    s.summary = <<-EOF
  CodeRay is a fast syntax highlighter engine for many languages.
    EOF
    s.description = <<-EOF
  CodeRay is a Ruby library for syntax highlighting.
  I try to make CodeRay easy to use and intuitive, but at the same time
  fully featured, complete, fast and efficient.

  Usage is simple:
    CodeRay.scan(code, :ruby).div
    EOF

    # Files
    s.require_path = 'lib'
    s.executables = [ 'coderay', 'coderay_stylesheet' ]

    s.files = nil  # defined later

    # Credits
    s.author = 'murphy'
    s.email = 'murphy@rubychan.de'
    s.homepage = 'http://coderay.rubychan.de'
  end
end

namespace :gem do

  gemtask = Rake::GemPackageTask.new(gemspec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end

  desc 'Create the Gem again'
  task :make => [:make_gemspec, :clean, :gem]

  desc 'Delete previously created Gems'
  task :clean do
    Dir['pkg/*.gem'].each { |g| rm g }
  end

  desc 'Find out the current CodeRay version'
  task :get_version do
    $gem_name = 'coderay'
    unless $version
      $: << './lib'
      require 'coderay'
      $version = CodeRay::VERSION
    end
    puts 'Current Version: %s' % $version
    if $version[/.0$/]
      sh 'svn up --ignore-externals'
      $version << '.' << `svn info`[/Revision: (\d+)/,1]
      $gem_name << '-beta'
    end
    if ENV['pre']
      $version << '.' << `svn info`[/Revision: (\d+)/,1]
      $version << '.pre'
    end
  end

  task :make_gemspec => :get_version do
    s = gemtask.gem_spec
    s.files = Dir['./lib/**/*.rb'] +
      Dir['./demo/*.rb'] +
      Dir['./Rakefile'] +
      Dir['./test/functional/*'] +
      %w(./lib/README ./LICENSE)
    s.test_file = './test/functional/suite.rb'
    gemtask.version = s.version = $version
    gemtask.name = s.name = $gem_name
  end
  
  task :set_pre do
    ENV['pre'] = 'true'
  end
  
  desc 'Make a prerelease Gem.'
  task :prerelease => [:set_pre, :make]
  
end

task :gem => 'gem:make'