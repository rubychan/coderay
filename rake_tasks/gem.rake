require 'rake/gempackagetask.rb'

def gemspec
  Gem::Specification.new do |s|
    # Basic Information
    s.name = s.rubyforge_project = 'coderay'
    s.version = '0'

    s.platform = Gem::Platform::RUBY
    s.required_ruby_version = '>= 1.8.2'
    s.requirements = ['strscan']
    s.date = Time.now.strftime '%Y-%m-%d'
    s.has_rdoc = true
    s.rdoc_options = '-SNw2', '-mREADME', '-a', '-t CodeRay Documentation'
    s.extra_rdoc_files = EXTRA_FILES.in('./')

    # Description
    s.summary = <<-EOF
  CodeRay is a fast syntax highlighter engine for many languages.
    EOF
    s.description = <<-EOF
  CodeRay is a Ruby library for syntax highlighting.
  I try to make CodeRay easy to use and intuitive, but at the same time
  fully featured, complete, fast and efficient.

  Usage is simple:
    require 'coderay'
    code = 'some %q(weird (Ruby) can\'t shock) me!'
    puts CodeRay.scan(code, :ruby).html
    EOF

    # Files
    s.require_path = 'lib'
    s.autorequire = 'coderay'
    s.executables = [ 'coderay' ]

    s.files = nil  # defined later

    # Credits
    s.author = 'murphy'
    s.email = 'murphy@cYcnus.de'
    s.homepage = 'http://coderay.rubychan.de'
  end
end

namespace :gem do

  gemtask = Rake::GemPackageTask.new(gemspec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end

  desc 'Create the gem again'
  task :make => [:make_gemspec, :clean, :gem, :prepare_server]

  desc 'Delete previously created Gems'
  task :clean do
    Dir['pkg/*.gem'].each { |g| rm g }
  end

  desc 'Find out the current CodeRay version'
  task :get_version do
    unless $version
      $: << './lib'
      require 'coderay'
      $version = CodeRay::Version
    end
    puts 'Current Version: %s' % $version
    #$version.sub!(/\.(\d+)\./) { minor = $1; ".#{minor.to_i}." }
    $version << '.' << (`svn info`[/Revision: (\d+)/,1])
  end

  task :make_gemspec => :get_version do
    candidates = Dir['./lib/**/*.rb'] +
      Dir['./demo/*.rb'] +
      #    Dir['./bin/*'] +
      #    Dir['./demo/bench/*'] +
      #    Dir['./test/*'] +
      %w( ./README ./LICENSE)
    s = gemtask.gem_spec
    s.files = candidates #.delete_if { |item| item[/(?:CVS|rdoc)|~$/] }
    gemtask.version = s.version = $version
  end

  GEMDIR = 'gem_server/gems'
  task :prepare_server => :get_version do
    $gemfile = "coderay-#$version.gem"
    Dir[GEMDIR + '/*.gem'].each { |g| rm g }
    cp "pkg/#$gemfile", GEMDIR
    system 'ruby -S index_gem_repository.rb -d gem_server'
  end

  desc 'Upload gemfile to ' + FTP_DOMAIN
  task :upload => :make do
    gn 'Uploading gem:'
    cYcnus_ftp do |ftp|
      Dir.chdir 'gem_server' do
        uploader = uploader_for ftp
        ftp.chdir FTP_CODERAY_DIR
        %w(yaml yaml.Z).each &uploader
        Dir.chdir 'gems' do
          ftp.chdir 'gems'
          uploader.call $gemfile
        end
      end
    end
    gn 'Gem successfully uploaded.'
  end

  desc 'Build the Gem and install it locally'
  task :install => :make do
    system "ruby -S gem install --no-rdoc pkg/#{$gemfile}"
  end

end
