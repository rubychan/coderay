verbose false

ROOT = '.'
LIB_ROOT = File.join ROOT, 'lib'

desc 'Run CodeRay tests (basic).'
task :test do
  ruby "./test/functional/suite.rb"
  ruby "./test/functional/for_redcloth.rb"
end
task :default => :test

for task_file in Dir['rake_tasks/*.rake'].sort
  load task_file
end if File.directory? 'rake_tasks'

