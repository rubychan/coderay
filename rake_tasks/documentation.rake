require 'rake/rdoctask'
require 'pathname'

CODERAY_TEMPLATE = Pathname.new(File.dirname(__FILE__)).join('..', 'rake_helpers', 'coderay_rdoc_template.rb').expand_path.to_s

def set_rdoc_info rd
  rd.main = 'README'
  rd.title = "CodeRay Documentation"
  rd.options << '--line-numbers' << '--inline-source' << '--tab-width' << '2'
  # rd.options << '--format' << ENV.fetch('format', 'html_coderay')
  rd.options << '--all'
  
  rd.template = ENV.fetch('template', CODERAY_TEMPLATE)
  rd.rdoc_files.add(*EXTRA_FILES.in(ROOT))
  rd.rdoc_files.add(*Dir[File.join(LIB_ROOT, "**/*.rb")])
end

namespace :doc do

  desc 'Generate documentation for CodeRay'
  Rake::RDocTask.new :all do |rd|
    set_rdoc_info rd
    rd.rdoc_dir = 'doc/all'
  end

  desc 'Upload rdoc to ' + FTP_DOMAIN
  task :upload => :all do
    gn 'Uploading documentation:'
    Dir.chdir 'doc/all' do
      cYcnus_ftp do |ftp|
        uploader = uploader_for ftp
        ftp.chdir FTP_CODERAY_DIR
        ftp.chdir 'doc'
        Dir['**/*.*'].each(&uploader)
      end
    end
    gn 'Documentation uploaded.'
  end

end

task :doc => 'doc:all'
