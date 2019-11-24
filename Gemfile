source 'https://rubygems.org'

# Specify your gem's dependencies in coderay.gemspec
gemspec

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'bundler'
  gem 'json', '>= 1.8' if RUBY_VERSION < '1.9'
  gem 'rake',             RUBY_VERSION < '1.9' ? '~> 10.5'    : '>= 10.5'
  gem 'rdoc',             Gem::Version.new(RUBY_VERSION) < Gem::Version.new('1.9.3') ? '~> 4.2.2' : Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2.2') ? '< 6' : '>= 6'
  gem 'RedCloth',         RUBY_PLATFORM == 'java' ? '= 4.2.9' : '>= 4.0.3'
  gem 'rspec',            '~> 3.9.0'
  gem 'shoulda-context',  RUBY_VERSION < '1.9' ? '= 1.2.1'    : '>= 1.2.1'
  gem 'simplecov',        '~> 0.17.1'
  gem 'term-ansicolor',   RUBY_VERSION < '2.0' ? '~> 1.3.2'   : '>= 1.3.2'
  gem 'test-unit',        RUBY_VERSION < '1.9' ? '~> 2.0'     : '>= 3.0'
  gem 'tins',             RUBY_VERSION < '2.0' ? '~> 1.6.0'   : '>= 1.6.0'
end
