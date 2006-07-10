$saveable = 0.0

puts
puts 'Searching for vim backup files...'
puts

for sw in Dir['**/.*.sw*']
  file = File.join(File.dirname(sw), File.basename(sw)[/^.(.*).sw.$/, 1])

  status =
    if not File.exist? file
      'MISSING!'
    elsif File.mtime(sw) > File.mtime(file)
      'changed'
    else
      'deprecated'
    end
  deprecated = (status == 'deprecated' or ARGV.include? '-A')

  size = File.size(sw).to_f / 1024
  $saveable += size if deprecated

  action =
    if ARGV.include? '-D'
      if deprecated
        begin
          File.delete sw
        rescue => boom
          boom.class.name
        else
          'delete'
        end
      end
    else
      ''
    end

  puts "  %-13s [%3.0f KB]  %-60s  %-13s" % [
    status, size, file, action]
end

puts
puts '%3.0f KB can be saved.' % $saveable
