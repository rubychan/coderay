$:.push File.expand_path("../lib", __FILE__)

require 'coderay/version'

Gem::Specification.new do |s|
  s.name = 'coderay'
  
  if ENV['final'] == 'yes'
    s.version = CodeRay::VERSION
  else
    # thanks to @Argorak for this solution
    revision = 134 + (`git log --oneline | wc -l`.to_i)
    s.version = "#{CodeRay::VERSION}.#{revision}pre"
  end
  
  s.authors     = ['Kornelius Kalnbach']
  s.email       = ['murphy@rubychan.de']
  s.homepage    = 'http://coderay.rubychan.de'
  s.summary     = 'Fast syntax highlighting for selected languages.'
  s.description = 'Fast and easy syntax highlighting for selected languages, written in Ruby. Comes with RedCloth integration and LOC counter.'
  
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.7'
  
  # s.add_dependency "paint", '~> 0.8.2'
  
  # s.files         = `git ls-files`.split("\n")
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  # s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  # s.require_paths = ["lib"]
  readme_file = 'README_INDEX.rdoc'
  
  s.files         = Dir['lib/**/*.rb'] + %W(Rakefile #{readme_file} LICENSE) + Dir['test/functional/*.rb']
  s.test_files    = Dir['test/functional/*.rb']
  s.executables   = ['coderay']
  s.require_paths = ['lib']
  
  s.rubyforge_project = s.name
  s.rdoc_options      = '-SNw2', "-m#{readme_file}", '-t CodeRay Documentation'
  s.extra_rdoc_files  = readme_file
end
