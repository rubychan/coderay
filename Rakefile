# excuse me, this is my first Rakefile :(  [m]
require 'rake'
require 'rake_helpers/rdoctask2'
require 'rake/gempackagetask.rb'

ROOT = ''
LIB_ROOT = ROOT + 'lib/'

task :default => :make

#task :doc => [:deldoc, :make_doc]
#task :minidoc => [:deldoc, :make_minidoc]
#task :deldoc do
#	rm_r 'doc' if File.directory? 'doc'
#end

def set_rdoc_info rd, small = false
#	rd.rdoc_dir = 'doc'
	rd.main = ROOT + 'README'
	rd.title = "CodeRay Documentation"
	rd.options << '--line-numbers' << '--inline-source' << '--tab-width' << '2'
	rd.options << '--fmt' << 'html_coderay'
	rd.options << '--all'
	rd.template = 'rake_helpers/coderay_rdoc_template.rb'
	rd.rdoc_files.add ROOT + 'README'
	rd.rdoc_files.add *Dir[LIB_ROOT + "#{'**/' unless small}*.rb"]
end

desc 'Generate documentation for CodeRay'
Rake::RDocTask.new :rdoc do |rd|
	set_rdoc_info rd
end

desc 'Generate test documentation for CodeRay'
Rake::RDocTask.new :rdoc_small do |rd|
	set_rdoc_info rd, true
end

desc 'Report code statistics (LOC) from the application'
task :stats => :copy_files do
	require 'rake_helpers/code_statistics'
	CodeStatistics.new(
		['Main', 'lib'],
		['CodeRay', 'lib/coderay/'],
		['  Scanners', 'lib/coderay/scanners'],
		['  Encoders', 'lib/coderay/encoders'],
		['  Helpers', 'lib/coderay/helpers'],
		['Test', 'test/**', /\/\w+.rb$/],
		['Demo Tests', 'demo/**']
	).print
end

desc 'Test CodeRay Demos'
task :test_demos do
	system 'ruby -wd ./demo/suite.rb'
end

desc 'Test CodeRay'
task :test do
	system 'ruby -w ./test/suite.rb'
end

desc 'Test CodeRay Demos with Fox'
task :testf_demos do
	system 'ruby -w ./demo/suite.rb -f'
end

desc 'Test CodeRay with Fox'
task :testf do
	system 'ruby -w ./test/suite.rb -f'
end

desc 'Test CodeRay with debugging'
task :debug do
	system 'ruby -w -d ./test/suite.rb'
end

desc 'Do a benchmark'
task :bench do
	system 'ruby -wIlib bench\bench.rb ruby html 0'
end

def gemspec
	Gem::Specification.new do |s|
		# Basic Information
		s.name = s.rubyforge_project = 'coderay'
		s.version = '0'
		
		s.platform = Gem::Platform::RUBY
		s.requirements = ['strscan']
		s.date = Time.now.strftime '%Y-%m-%d'
		s.has_rdoc = true
		s.rdoc_options = '-SNw2', '-mREADME', '-a', '-t CodeRay Documentation'
		s.extra_rdoc_files = %w(./README)

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

  	s.files = nil  # defined later		

		# Credits
		s.author = 'murphy'
		s.email = 'murphy@cYcnus.de'
		s.homepage = 'http://rd.cycnus.de/coderay'
	end
end

gemtask = Rake::GemPackageTask.new(gemspec) do |pkg|
	pkg.need_zip = true
	pkg.need_tar = true
end

$: << './lib'
require 'coderay'
$version = CodeRay::Version

desc 'Create the gem again'
task :make => [:build, :make_gem]

BUILD_FILE = 'build'
task :build do
	$version.sub!(/\.(\d+)\./) { minor = $1; ".#{minor.to_i - 1}." }
	$version << '.' << (`svn info`[/Revision: (\d+)/,1])
end

task :make_gem => [:copy_files, :make_gemspec, :gem, :copy_gem]

desc 'Copy the gem files'
task :copy_files do
	rm_r 'pkg' if File.exist? 'pkg'
end

task :make_gemspec do
	candidates = Dir['./lib/**/*.rb'] +
		Dir['./demo/*.rb'] +
#		Dir['./bin/*'] +
#		Dir['./demo/bench/*'] +
#		Dir['./test/*'] +
		%w( ./README ./LICENSE)
	s = gemtask.gem_spec
	s.files = candidates #.delete_if { |item| item[/(?:CVS|rdoc)|~$/] }
	gemtask.version = s.version = $version
end

GEMDIR = 'gem_server/gems'
task :copy_gem => :build do
	$gemfile = "coderay-#$version.gem"
	Dir[GEMDIR + '/*.gem'].each { |g| rm g }
	cp "pkg/#$gemfile", GEMDIR
	system 'ruby -S generate_yaml_index.rb -d gem_server'
end

def g msg
	$stderr.print msg
end
def gn msg = ''
	$stderr.puts msg
end
def gd
	gn 'done.'
end

require 'net/ftp'
require 'yaml'
FTP_YAML = 'ftp.yaml'
$username = File.exist?(FTP_YAML) ? YAML.load_file(FTP_YAML)[:username] : 'anonymous'

FTP_DOMAIN = 'cycnus.de'
FTP_CODERAY_DIR = 'public_html/raindark/coderay'

def cYcnus_ftp
	Net::FTP.open(FTP_DOMAIN) do |ftp|
		g 'ftp login, password needed: '
		ftp.login $username, $stdin.gets
		gn 'logged in.'
		yield ftp
	end
end

def uploader_for ftp
	proc do |l, *r|
		r = r.first || l
		raise 'File %s not found!' % l unless File.exist? l
		if l == r
			g 'Uploading %s...' % [l]
		else
			g 'Uploading %s to %s...' % [l, r]
		end
		ftp.putbinaryfile l, r
		gd
	end
end

desc 'Upload gemfile to ' + FTP_DOMAIN
task :up_gem => [:make, :copy_gem] do
	gn 'Uploading gem:'
	Dir.chdir 'gem_server' do
		cYcnus_ftp do |ftp|
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

desc 'Upload example to ' + FTP_DOMAIN
task :up_example do
	gn 'Highlighting self...'
	system 'ruby -wIlib ../hidden/highlight.rb -1 -L -I lib lib/coderay/**/'
	gd
	gn 'Uploading example:'
	cYcnus_ftp do |ftp|
		ftp.chdir FTP_CODERAY_DIR
		uploader = proc do |l, r|
			g 'Uploading %s to %s...' % [l, r]
			ftp.putbinaryfile l, r
			gd
		end
		uploader.call 'highlighted/all_in_one.html', 'example.html'
	end
	gn 'Example uploaded.'
end

desc 'Upload rdoc to ' + FTP_DOMAIN
task :up_doc => :rdoc do
	gn 'Uploading documentation:'
	Dir.chdir 'rdoc' do
		cYcnus_ftp do |ftp|
			uploader = uploader_for ftp
			ftp.chdir FTP_CODERAY_DIR
			ftp.chdir 'doc'
			Dir['**/*.*'].each &uploader
		end
	end
	gn 'Documentation uploaded.'
end

RUBYFORGE_TRUNK_DIR = 'L:/rubyforge/trunk/coderay/trunk'
desc 'Export trunk to Rubyforge working copy via SVN'
task :export do
	system 'svn st'
	puts 'Exporting changelog.'
	system 'svn log > ../changelog.txt'
	system "svn export #{`svn info`[/URL: (.*)/,1]}/ #{RUBYFORGE_TRUNK_DIR} --force"
	cp '../changelog.txt', "#{RUBYFORGE_TRUNK_DIR}/.."
	Dir.chdir RUBYFORGE_TRUNK_DIR do
		system "svn st"
	end
end
