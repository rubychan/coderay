if RUBY_VERSION >= '1.8.7'
  gem 'rdoc' if defined? gem
  require 'rdoc/task'
else
  require 'rake/rdoctask'
end

desc 'Generate documentation for CodeRay'
Rake::RDocTask.new :doc do |rd|
  rd.main = 'lib/README'
  rd.title = 'CodeRay Documentation'
  
  rd.options << '--line-numbers' << '--inline-source' << '--tab-width' << '2'
  rd.options << '--fmt' << ENV.fetch('format', 'html_coderay')
  require 'pathname'
  template = File.join ROOT, 'rake_helpers', 'coderay_rdoc_template.rb'
  rd.template = Pathname.new(template).expand_path.to_s
  
  rd.rdoc_files.add 'README.rdoc'
  rd.rdoc_files.add Dir['lib']
  rd.rdoc_dir = 'doc'
end

desc 'Copy the documentation over to the CodeRay website'
task :copy_doc do
  cp_r 'doc/.', '../../rails/coderay/public/doc'
end
