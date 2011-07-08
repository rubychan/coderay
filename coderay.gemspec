# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

def svn_head_revision
  $svn_head_revision ||= `svnversion`.scan(/\d+/).map { |r| r.to_i }.max
end

def coderay_version
  $coderay_version ||= begin
    $:.unshift './lib'
    require 'coderay'
    
    version = CodeRay::VERSION
    unless ENV['final']
      version << ".#{svn_head_revision}.pre"
    end
    
    version
  end
end

$gemspec = Gem::Specification.new do |s|
  s.name        = 'coderay'
  s.version     = coderay_version
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Kornelius Kalnbach']
  s.email       = ['murphy@rubychan.de']
  s.homepage    = 'http://coderay.rubychan.de'
  s.summary     = 'Fast syntax highlighting for selected languages.'
  s.description = 'Fast and easy syntax highlighting for selected languages, written in Ruby. Comes with RedCloth integration and LOC counter.'
  
  # s.add_dependency "paint", '~> 0.8.2'
  
  # s.files         = `git ls-files`.split("\n")
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  # s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  # s.require_paths = ["lib"]
  s.files         = Dir['lib/**/*.rb'] + %w(Rakefile README.rdoc LICENSE) + Dir['test/functional/*.rb']
  s.test_files    = Dir['test/functional/*.rb']
  s.executables   = ['coderay']
  s.require_paths = ['lib']
  
  s.rubyforge_project = s.name
  s.rdoc_options      = '-SNw2', '-mREADME.rdoc', '-t CodeRay Documentation'
  s.extra_rdoc_files  = 'README.rdoc'
end
