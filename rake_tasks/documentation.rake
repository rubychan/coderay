begin
  if RUBY_VERSION >= '1.8.7'
    gem 'rdoc' if defined? gem
    require 'rdoc/task'
  else
    require 'rake/rdoctask'
  end
rescue LoadError
  warn 'Please gem install rdoc.'
end

desc 'Generate documentation for CodeRay'
Rake::RDocTask.new :doc do |rd|
  rd.main = 'lib/README'
  rd.title = 'CodeRay Documentation'
  
  rd.options << '--line-numbers' << '--tab-width' << '2'
  
  rd.main = 'README_INDEX.rdoc'
  rd.rdoc_files.add 'README_INDEX.rdoc'
  rd.rdoc_files.add Dir['lib']
  rd.rdoc_dir = 'doc'
end if defined? Rake::RDocTask
