require 'rubygems/package_task'

def svn_head_revision
  @svn_head_revision ||= `svn up --ignore-externals && svn info`[/Revision: (\d+)/,1]
end

def coderay_version
  @coderay_version ||= begin
    $:.unshift './lib'
    require 'coderay'
    
    version = CodeRay::VERSION
    if ENV['pre']
      version + ".#{svn_head_revision}.pre"
    elsif version[/.0$/]
      version + ".#{svn_head_revision}"
    end
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
    
    s.files         = Dir['lib/**/*.rb'] + %w(Rakefile lib/README LICENSE) + Dir['test/functional/*.rb']
    s.test_files    = Dir['test/functional/*.rb']
    s.executables   = [ 'coderay', 'coderay_stylesheet' ]
    s.require_paths = ['lib']
    
    s.rubyforge_project = s.name
    s.rdoc_options      = '-SNw2', '-mlib/README', '-t CodeRay Documentation'
    s.extra_rdoc_files  = EXTRA_RDOC_FILES
  end
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
    Dir['pkg/*.gem'].each { |g| rm g }
  end
  
  task :set_pre do
    ENV['pre'] = 'true'
  end
  
  desc 'Make a prerelease Gem.'
  task :prerelease => [:set_pre, :make]
end

task :gem => 'gem:make'