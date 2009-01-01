require 'rake_helpers/ftp.rb'

verbose false

ROOT = '.'
LIB_ROOT = File.join ROOT, 'lib'
RUBY = ENV.fetch 'ruby', 'ruby'

EXTRA_FILES = %w(README FOLDERS)
def EXTRA_FILES.in folder
  map do |file_name|
    File.join folder, file_name
  end
end

task :default => :test

task :upload => %w( gem:upload doc:upload example:upload )

def ruby command
  params =
    if RUBY == 'rbx'
      '-I/usr/local/lib/ruby/1.8'
    else
      '-w'
    end
  cmd = "#{RUBY} #{params} #{command}"
  puts cmd if verbose
  system cmd
end

task '19' do
  RUBY.replace 'ruby19'
end

task '18' do
  RUBY.replace 'ruby18'
end

task '187' do
  RUBY.replace 'ruby187'
end

task 'jruby' do
  RUBY.replace 'jruby'
end

task 'rubinius' do
  RUBY.replace 'rbx'
end

task 'ee' do
  RUBY.replace 'rubyee'
end

for task_file in Dir['rake_tasks/*.rake']
  load task_file
end

