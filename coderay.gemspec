$:.push File.expand_path("../lib", __FILE__)

require 'coderay/version'

Gem::Specification.new do |s|
  s.name = 'coderay'
  
  if ENV['RELEASE']
    s.version = CodeRay::VERSION
  else
    s.version = "#{CodeRay::VERSION}.rc#{ENV['RC'] || 1}"
  end
  
  s.authors     = ['Kornelius Kalnbach']
  s.email       = ['murphy@rubychan.de']
  s.homepage    = 'http://coderay.rubychan.de'
  s.summary     = 'Fast syntax highlighting for selected languages.'
  s.description = 'Fast and easy syntax highlighting for selected languages, written in Ruby. Comes with RedCloth integration and LOC counter.'
  
  s.license = 'MIT'
  
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.6'
  
  readme_file = 'README_INDEX.rdoc'
  
  s.files         = `git ls-files -- lib/* test/functional/* Rakefile #{readme_file} MIT-LICENSE`.split("\n")
  s.test_files    = `git ls-files --       test/functional/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  
  s.rubyforge_project = s.name
  s.rdoc_options      = '-SNw2', "-m#{readme_file}", '-t CodeRay Documentation'
  s.extra_rdoc_files  = readme_file
end
