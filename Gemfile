source 'https://rubygems.org'

# Specify your gem's dependencies in coderay.gemspec
gemspec

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'bundler'
  gem 'rake',             '>= 10.5'
  gem 'rdoc',             Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2.2') ? '< 6' : '>= 6'
  gem 'RedCloth',         RUBY_PLATFORM == 'java' ? '= 4.2.9' : '>= 4.0.3'
  gem 'rspec',            '~> 3.9.0'
  gem 'shoulda-context',  '>= 1.2.1'
  gem 'simplecov',        RUBY_VERSION < '2.7' ? '~> 0.17.1'  : '>= 0.18.5'
  gem 'term-ansicolor',   '>= 1.3.2'
  gem 'test-unit',        '>= 3.0'
  gem 'tins',             '>= 1.6.0'
end
