require 'rubygems/package_task'

load File.expand_path('../../coderay.gemspec', __FILE__)

def gem_path
  "pkg/coderay-#{coderay_version}.gem"
end

namespace :gem do
  Gem::PackageTask.new $gemspec do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end
  
  desc 'Create the Gem again'
  task :make => [:clean, :gem] do
    puts "Created #{coderay_version}"
  end
  
  desc 'Delete previously created Gems'
  task :clean do
    rm_r Dir['pkg/*']
  end
  
  desc 'Install the gem'
  task :install => [:make] do
    sh "gem install #{gem_path}"
  end
  
  desc 'Release the gem on rubygems.org'
  task :release => [:make] do
    print "Releasing CodeRay #{coderay_version}. Are you sure? "
    if $stdin.gets.chomp == 'yes'
      sh "gem push #{gem_path}"
    end
  end
end

task :gem => 'gem:make'