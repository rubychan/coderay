require 'rake_helpers/ftp.rb'

ROOT = '.'
LIB_ROOT = File.join ROOT, 'lib'

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
