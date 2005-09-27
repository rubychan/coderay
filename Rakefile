# excuse me, this is my first Rakefile :(  [m]
require 'rake'
require 'rdoctask2'
require 'rake/gempackagetask.rb'

ROOT = ''
LIB_ROOT = ROOT + 'lib/'

task :default => :make

task :doc => [:deldoc, :rdoc]
task :deldoc do
	rm_r 'doc' if File.directory? 'doc'
end

desc 'Generate documentation for CodeRay'
Rake::RDocTask.new :rdoc do |rd|
	rd.rdoc_dir = 'doc'
	rd.main = ROOT + 'README'
	rd.title = "CodeRay Documentation"
	rd.options << '--line-numbers' << '--inline-source' << '--tab-width' << '2'
	rd.options << '--fmt' << 'html_coderay'
	rd.options << '--all'
	rd.template = 'rake_helpers/coderay_rdoc_template.rb'
	rd.rdoc_files.add ROOT + 'README'
	rd.rdoc_files.add *Dir[LIB_ROOT + '*.rb']
#	rd.rdoc_files.include ROOT + 'coderay/scanners/*.rb'
#	rd.rdoc_files.include ROOT + 'coderay/scanners/helpers/*.rb'
#	rd.rdoc_files.include ROOT + 'coderay/encoders/*.rb'
#	rd.rdoc_files.include ROOT + 'coderay/encoders/helpers/*.rb'
#	rd.rdoc_files.include ROOT + 'coderay/helpers/*.rb'
end

desc 'Report code statistics (LOC) from the application'
task :stats => :copy_files do
	require 'code_statistics'
	CodeStatistics.new(
		["Main", "lib"]
	).to_s
end

desc 'Test CodeRay'
task :test do
	system 'ruby -w ./test/suite.rb'
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
		s.rdoc_options = '-SNw2', '-mREADME', '-a'
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
	$version.sub!(/\d+$/) { |minor| minor.to_i - 1 }
	$version << '.' << File.read(BUILD_FILE)[/\d+/]
end

task :make_gem => [:copy_files, :make_gemspec, :gem, :copy_gem]

desc 'Copy the gem files'
task :copy_files do
	rm_r 'pkg' if File.exist? 'pkg'
end

task :make_gemspec do
	candidates = Dir['./**/*.rb'] +
#		Dir['./demo/demo_*.rb'] +
		Dir['./bin/*'] +
#		Dir['./demo/bench/*'] +
#		Dir['./test/*'] +
		%w( ./README ./LICENSE)
	s = gemtask.gem_spec
	s.files = candidates #.delete_if { |item| item[/(?:CVS|rdoc)|~$/] }
	gemtask.version = s.version = $version
end

GEMDIR = 'gem_server/gems'
task :copy_gem do
	$gemfile = "coderay-#$version.gem"
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

def cYcnus_ftp
	Net::FTP.open('cycnus.de') do |ftp|
		g 'ftp login, password needed: '
		ftp.login $username, $stdin.gets
		gn 'logged in.'
		yield ftp
	end
end

task :upload_gem do
	gn 'Uploading gem:'
	Dir.chdir 'gem_server' do
		cYcnus_ftp do |ftp|
			uploader = proc do |f|
				raise 'File %s not found!' % f unless File.exist? f
				g 'Uploading %s...' % f
				ftp.putbinaryfile f, f
				gd
			end
			ftp.chdir 'public_html/raindark/coderay'
			%w(yaml yaml.Z).each &uploader
			Dir.chdir 'gems' do
				ftp.chdir 'gems'
				uploader.call $gemfile
			end
		end
	end
	gn 'Gem successfully uploaded.'
end

task :example do
	Dir.chdir 'demo' do
		g 'Highlighting self...'
		system 'ruby -w highlight_self.rb -o -L'
		gd
		gn 'Uploading example:'
		cYcnus_ftp do |ftp|
			ftp.chdir 'public_html/raindark/coderay'
			uploader = proc do |l, r|
				g 'Uploading %s to %s...' % [l, r]
				ftp.putbinaryfile l, r
				gd
			end
			uploader.call 'highlight_self/all_in_one.html', 'example.html'
		end
		gn 'Example uploaded.'
	end
end
