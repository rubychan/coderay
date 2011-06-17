require 'rubygems/package_task'

def svn_head_revision
  @svn_head_revision ||= `svnversion`.scan(/\d+/).map { |r| r.to_i }.max
end

def coderay_version
  @coderay_version ||= begin
    $:.unshift './lib'
    require 'coderay'
    
    version = CodeRay::VERSION
    unless ENV['final']
      version << ".#{svn_head_revision}.pre"
    end
    
    version
  end
end

def gemspec
  Gem::Specification.new do |s|
    s.name        = 'coderay'
    s.version     = coderay_version
    s.platform    = Gem::Platform::RUBY
    s.authors     = ['murphy']
    s.email       = ['murphy@rubychan.de']
    s.homepage    = 'http://coderay.rubychan.de'
    s.summary     = 'Fast syntax highlighting for selected languages.'
    s.description = 'Fast and easy syntax highlighting for selected languages, written in Ruby. Comes with RedCloth integration and LOC counter.'
    
    s.files         = Dir['lib/**/*.rb'] + %w(Rakefile README.rdoc LICENSE) + Dir['test/functional/*.rb']
    s.test_files    = Dir['test/functional/*.rb']
    s.executables   = ['coderay']
    s.require_paths = ['lib']
    
    s.rubyforge_project = s.name
    s.rdoc_options      = '-SNw2', '-mREADME.rdoc', '-t CodeRay Documentation'
    s.extra_rdoc_files  = EXTRA_RDOC_FILES
  end
end

def gem_path
  "pkg/coderay-#{coderay_version}.gem"
end

namespace :gem do
  Gem::PackageTask.new gemspec do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end
  
  desc 'Create the Gem again'
  task :make => [:clean, :gem] do
    puts "Created #{coderay_version}"
  end
  
  desc 'Delete previously created Gems'
  task :clean do
    rm_r Dir['pkg/*']
  end
  
  desc 'Install the gem'
  task :install => [:make] do
    sh "gem install #{gem_path}"
  end
  
  desc 'Release the gem on rubygems.org'
  task :release => [:make] do
    print "Releasing CodeRay #{coderay_version}. Are you sure? "
    if $stdin.gets.chomp == 'yes'
      sh "gem push #{gem_path}"
    end
  end
end

task :gem => 'gem:make'