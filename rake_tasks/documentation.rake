require 'rake/rdoctask'
require 'pathname'

CODERAY_TEMPLATE = Pathname.new(File.dirname(__FILE__)).join('..', 'rake_helpers', 'coderay_rdoc_template.rb').expand_path.to_s

def set_rdoc_info rd
  rd.main = 'lib/README'
  rd.title = "CodeRay Documentation"
  rd.options << '--line-numbers' << '--inline-source' << '--tab-width' << '2'
  # rd.options << '--format' << ENV.fetch('format', 'html_coderay')
  rd.options << '--all'
  
  rd.template = ENV.fetch('template', CODERAY_TEMPLATE)
  rd.rdoc_files.add(*EXTRA_FILES.in(ROOT))
  rd.rdoc_files.add(*Dir[File.join(LIB_ROOT, 'coderay', '**', '*.rb')])
end

desc 'Generate documentation for CodeRay'
Rake::RDocTask.new :doc do |rd|
  set_rdoc_info rd
  rd.rdoc_dir = 'doc'
end
