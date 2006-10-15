RUBYFORGE_TRUNK_DIR = 'L:/rubyforge/trunk/coderay/trunk'
CODERAY_TRUNK_DIR = 'L:/root/trunk'

namespace :rubyforge do

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

  desc 'Export trunk to Rubyforge working copy via SVN'
  task :import do
    Dir.chdir RUBYFORGE_TRUNK_DIR do
      #system 'svn st'
      #puts 'Exporting changelog.'
      #system 'svn log > ../changelog.txt'
      system "svn export #{`svn info`[/URL: (.*)/,1]}/ #{CODERAY_TRUNK_DIR} --force"
    end
    #cp '../changelog.txt', "#{RUBYFORGE_TRUNK_DIR}/.."
    system "svn st"
  end

end

task :import => 'rubyforge:import'
task :export => 'rubyforge:export'
