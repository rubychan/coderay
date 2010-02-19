RUBY = ENV.fetch 'ruby', 'ruby'

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
task :j => :jruby

task 'jruby19' do
  RUBY.replace 'jruby --1.9'
end
task :j19 => :jruby19

task 'jruby-nailgun' do
  RUBY.replace 'jruby --ng'
end
task :jng => :'jruby-nailgun'

task 'rubinius' do
  RUBY.replace 'rbx'
end

task 'ee' do
  RUBY.replace 'rubyee'
end
