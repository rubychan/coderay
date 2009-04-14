namespace :generate do
  desc 'generates a new scanner NAME=lang [ALT=alternative,plugin,ids] [EXT=file,extensions] [BASE=base lang] '
  task :scanner do
    raise 'I need a scanner name; use NAME=lang' unless scanner_class_name = ENV['NAME']
    raise "Invalid lang: #{scanner_class_name}; use NAME=lang." unless /\A\w+\z/ === scanner_class_name
    require 'active_support'
    lang = scanner_class_name.underscore
    class_name = scanner_class_name.classify
    
    def scanner_file_for_lang lang
      File.join(LIB_ROOT, 'coderay', 'scanners', lang + '.rb')
    end
    
    scanner_file = scanner_file_for_lang lang
    if File.exist? scanner_file
      print "#{scanner_file} already exists. Overwrite? [y|N] "
      exit unless $stdin.gets.chomp.downcase == 'y'
    end
    
    base_lang = ENV.fetch('BASE', 'json')
    base_scanner_file = scanner_file_for_lang(base_lang)
    puts "Reading base scanner #{base_scanner_file}..."
    base_scanner = File.read base_scanner_file
    puts "Writing new scanner #{scanner_file}..."
    File.open(scanner_file, 'w') do |file|
      file.write base_scanner.
        sub(/class \w+ < Scanner/, "class #{class_name} < Scanner").
        sub(/register_for :\w+/, "register_for :#{lang}").
        sub(/file_extension '\S+'/, "file_extension '#{ENV.fetch('EXT', lang).split(',').first}'")
    end
    
    test_dir = File.join(ROOT, 'test', 'scanners', lang)
    unless File.exist? test_dir
      puts "Creating test folder #{test_dir}..."
      sh "mkdir #{test_dir}"
    end
    test_suite_file = File.join(test_dir, 'suite.rb')
    unless File.exist? test_suite_file
      puts "Creating test suite file #{test_suite_file}..."
      base_suite = File.read File.join(test_dir, '..', 'json', 'suite.rb')
      File.open(test_suite_file, 'w') do |file|
        file.write base_suite.sub(/class JSON/, "class #{class_name}")
      end
    end
    
    if extensions = ENV['EXT']
      file_type_file = File.join(LIB_ROOT, 'coderay', 'helpers', 'filetype.rb')
      puts "Not automated. Remember to add your extensions to #{file_type_file}:"
      for ext in extensions.split(',')
        puts "    '#{ext}' => :#{lang},"
      end
    end
    
    if alternative_ids = ENV['ALT']
      map_file = File.join(LIB_ROOT, 'coderay', 'scanners', '_map.rb')
      puts "Not automated. Remember to add your alternative plugin ids to #{map_file}:"
      for id in alternative_ids.split(',')
        puts "  :#{id} => :#{lang},"
      end
    end
    
    print 'Add to SVN? [Y|n] '
    answer = $stdin.gets.chomp.downcase
    if answer.empty? || answer == 'y'
      sh "svn add #{scanner_file}"
      sh "svn add #{test_dir}"
      svn_ignore = <<-SVN_IGNORE
*.actual.*
*.expected.html
*.debug.diff
      SVN_IGNORE
      sh "svn pset svn:ignore '#{svn_ignore}' #{test_dir}"
    end
  end
end
