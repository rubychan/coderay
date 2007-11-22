require 'rake_helpers/ftp.rb'

ROOT = '.'
LIB_ROOT = File.join ROOT, 'lib'
RUBY = ENV.fetch 'ruby', 'ruby'

EXTRA_FILES = %w(README FOLDERS)
def EXTRA_FILES.in folder
  map do |file_name|
    File.join folder, file_name
  end
end

for task_file in Dir['rake_tasks/*.rake']
  load task_file
end

task :default => 'gem:make'

task :upload => %w( gem:upload doc:upload example:upload )

task '19' do
  RUBY.replace 'ruby19'
end

task '18' do
  RUBY.replace '18ruby'
end

task 'yarv' do
  RUBY.replace 'ruby-yarv'
end

task 'jruby' do
  RUBY.replace 'jruby'
end

task 'rubinius' do
  RUBY.replace 'rbx'
end

if ruby = ENV['ruby']
  RUBY.replace ruby
end