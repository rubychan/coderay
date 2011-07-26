begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
rescue LoadError
  puts 'Please gem install bundler.'
end
