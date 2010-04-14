$VERBOSE = $CODERAY_DEBUG = true
require 'benchmark'
require 'yaml'
require 'fileutils'

$mydir = File.dirname(__FILE__)
$:.unshift File.join($mydir, '..', '..', 'lib')
require 'coderay'

$:.unshift File.join($mydir, '..', 'lib')

require 'term/ansicolor' unless ENV['nocolor']

require 'test/unit'

if defined? Term::ANSIColor
  class String
    include Term::ANSIColor
    def green_or_red result
      result ? green : red
    end
  end
else
  class String
    for meth in %w(green red blue cyan magenta yellow concealed white)
      class_eval <<-END
        def #{meth}
          self
        end
      END
    end
    def green_or_red result
      result ? upcase : downcase
    end
  end
end

unless defined? Term::ANSIColor
  puts 'You should gem install term-ansicolor.'
end

# from Ruby Facets (http://facets.rubyforge.org/)
class Array
  def shuffle!
    s = size
    each_index do |j|
      i = ::Kernel.rand(s-j)
      self[j], self[j+i] = at(j+i), at(j) unless i.zero?
    end
    self
  end unless [].respond_to? :shuffle!
end

# Wraps around an enumerable and prints the current element when iterated.
class ProgressPrinter
  
  attr_accessor :enum, :template
  attr_reader :progress
  
  def initialize enum, template = '(%p)'
    @enum = enum
    @template = template
    if ENV['showprogress']
      @progress = ''
    else
      @progress = nil
    end
  end
  
  def each
    for elem in @enum
      if @progress
        print "\b" * @progress.size
        @progress = @template % elem
        print @progress
      end
      yield elem
    end
  ensure
    print "\b" * progress.size if @progress
  end
  
  include Enumerable
  
end

module Enumerable
  def progress
    ProgressPrinter.new self
  end
end

module CodeRay
  
  require 'test/unit'
  
  class TestCase < Test::Unit::TestCase
    
    if ENV['deluxe']
      MAX_CODE_SIZE_TO_HIGHLIGHT = 500_000_000
      MAX_CODE_SIZE_TO_TEST = 500_000_000
      DEFAULT_MAX = 4096
    elsif ENV['fast']
      MAX_CODE_SIZE_TO_HIGHLIGHT = 5_000_000
      MAX_CODE_SIZE_TO_TEST = 1_000_000
      DEFAULT_MAX = 16
    else
      MAX_CODE_SIZE_TO_HIGHLIGHT = 10_000_000
      MAX_CODE_SIZE_TO_TEST = 10_000_000
      DEFAULT_MAX = 1024
    end
    
    class << self
      def inherited child
        CodeRay::TestSuite << child.suite
      end
      
      # Calls its block with the working directory set to the examples
      # for this test case.
      def dir
        examples = File.join $mydir, lang.to_s
        Dir.chdir examples do
          yield
        end
      end
      
      def lang
        @lang ||= name[/\w+$/].downcase
      end
      
      def extension extension = nil
        if extension
          @extension = extension.to_s
        else
          @extension ||= CodeRay::Scanners[lang].file_extension.to_s
        end
      end
    end
    
    # Create only once, for speed
    Tokenizer = CodeRay::Encoders[:debug].new
    
    def test_ALL
      puts
      scanner = CodeRay::Scanners[self.class.lang].new
      raise "No Scanner for #{self.class.lang} found!" if scanner.is_a? CodeRay::Scanners[nil]
      puts '    >> Testing '.magenta + scanner.class.title.cyan +
        ' scanner <<'.magenta
      puts
      
      time_for_lang = Benchmark.realtime do
        max = ENV.fetch('max', DEFAULT_MAX).to_i
        random_test scanner, max unless ENV['norandom'] || ENV['only']
        examples_test scanner, max unless ENV['noexamples']
      end
      
      puts 'Finished in '.green + '%0.2fs'.white % time_for_lang + '.'.green
    end
    
    def examples_test scanner, max
      self.class.dir do
        extension = 'in.' + self.class.extension
        path = "test/scanners/#{File.basename(Dir.pwd)}/*.#{extension}"
        print 'Loading examples in '.green + path.cyan + '...'.green
        examples = Dir["*.#{extension}"]
        if examples.empty?
          puts "No examples found!".red
        else
          puts '%d'.yellow % examples.size + " example#{'s' if examples.size > 1} found.".green
        end
        for example_filename in examples
          @known_issue_description = @known_issue_ticket_url = nil
          name = File.basename(example_filename, ".#{extension}")
          next if ENV['lang'] && ENV['only'] && ENV['only'] != name
          print '%20s'.cyan % name + ' '
          filesize = File.size(example_filename)
          amount = filesize
          human_filesize =
            if amount < 1024
              '%6.0f B   ' % [amount]
            else
              amount /= 1024.0
              if amount < 1024
                '%6.1f KiB ' % [amount]
              else
                amount /= 1024.0
                '%6.1f MiB ' % [amount]
              end
            end
          print human_filesize.yellow
          
          tokens = example_test example_filename, name, scanner, max
          
          if defined?(@time_for_encoding) && time = @time_for_encoding
            kilo_tokens_per_second = tokens.size / time / 1000
            print 'finished in '.green + '%5.2fs'.white % time
            if filesize >= 1024
              print ' ('.green + '%4.0f Ktok/s'.white % kilo_tokens_per_second + ')'.green
            end
            @time_for_encoding = nil
          end
          puts '.'.green
          if @known_issue_description
            print '                 KNOWN ISSUE: '.cyan
            print @known_issue_description.yellow
            puts
            print ' ' * 30
            if @known_issue_ticket_url
              puts 'See '.yellow + @known_issue_ticket_url.white + '.'.yellow
            else
              puts 'No ticket yet. Visit '.yellow +
                'http://redmine.rubychan.de/projects/coderay/issues/new'.white + '.'.yellow
            end
          end
        end
      end
    end
    
    def example_test example_filename, name, scanner, max
      if File.size(example_filename) > MAX_CODE_SIZE_TO_TEST and not ENV['only']
        print 'too big'
        return
      end
      code = File.open(example_filename, 'rb') { |f| break f.read }
      
      incremental_test scanner, code, max unless ENV['noincremental']
      
      unless ENV['noshuffled'] or code.size < [0].pack('Q').size
        shuffled_test scanner, code, max
      else
        print '-skipped- '.concealed
      end
      
      tokens, ok, changed_lines = complete_test scanner, code, name
      
      identity_test scanner, tokens
      
      unless ENV['nohighlighting'] or (code.size > MAX_CODE_SIZE_TO_HIGHLIGHT and not ENV['only'])
        highlight_test tokens, name, ok, changed_lines
      else
        print '-- skipped -- '.concealed
      end
      tokens
    end
    
    def random_test scanner, max
      if defined?(JRUBY_VERSION) && JRUBY_VERSION == '1.4.0' && %w[ruby nitroxhtml rhtml].include?(scanner.lang)
        puts 'Random test skipped due to a bug in JRuby. See http://redmine.rubychan.de/issues/136.'.red
        @@warning_about_jruby_bug = true
        return
      end
      print "Random test...".yellow
      okay = true
      for size in (0..max).progress
        srand size + 17
        scanner.string = Array.new(size) { rand 256 }.pack 'c*'
        begin
          scanner.tokenize
        rescue
          assert_nothing_raised "Random test failed at #{size} #{RUBY_VERSION < '1.9' ? 'bytes' : 'chars'}" do
            raise
          end if ENV['assert']
          okay = false
          break
        end
      end
      print "\b" * 'Random test...'.size
      print 'Random test'.green_or_red(okay)
      puts ' - finished.'.green
    end
    
    def incremental_test scanner, code, max
      report 'incremental' do
        okay = true
        for size in (0..max).progress
          break if size > code.size
          scanner.string = code[0,size]
          begin
            scanner.tokenize
          rescue
            assert_nothing_raised "Incremental test failed at #{size} #{RUBY_VERSION < '1.9' ? 'bytes' : 'chars'}!" do
              raise
            end if ENV['assert']
            okay = false
            break
          end
        end
        okay
      end
    end
    
    def shuffled_test scanner, code, max
      report 'shuffled' do
        code_bits = code[0,max].unpack('Q*')  # split into quadwords...
        okay = true
        for i in (0..max / 4).progress
          srand i
          code_bits.shuffle!                     # ...mix...
          scanner.string = code_bits.pack('Q*')  # ...and join again
          begin
            scanner.tokenize
          rescue
            assert_nothing_raised 'shuffle test failed!' do
              raise
            end if ENV['assert']
            okay = false
            break
          end
        end
        okay
      end
    end
    
    def complete_test scanner, code, name
      print 'complete...'.yellow
      expected_filename = name + '.expected.' + Tokenizer.file_extension
      scanner.string = code
      
      tokens = result = nil
      @time_for_encoding = Benchmark.realtime do
        tokens = scanner.tokens
        result = Tokenizer.encode_tokens tokens
      end
      
      if File.exist?(expected_filename) && !(ENV['lang'] && ENV['new'] && name == ENV['new'])
        expected = File.open(expected_filename, 'rb') { |f| break f.read }
        if result.respond_to?(:bytesize) && result.bytesize != result.size
          # for char, i in result.chars.with_index
          #   raise "result has non-ASCII-8BIT character in line #{result[0,i].count(?\n) + 1}" if char.bytesize != 1
          # end
          # UTF-8 encoded result; comparison needs to be done on binary level
          result.force_encoding('binary')
        end
        ok = expected == result
        unless ok
          actual_filename = expected_filename.sub('.expected.', '.actual.')
          File.open(actual_filename, 'wb') { |f| f.write result }
          diff = expected_filename.sub(/\.expected\..*/, '.debug.diff')
          system "diff --unified=0 --text #{expected_filename} #{actual_filename} > #{diff}"
          debug_diff = File.read diff
          changed_lines = []
          debug_diff.scan(/^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@/) do |offset, size|
            offset = offset.to_i
            size = (size || 1).to_i
            changed_lines.concat Array(offset...offset + size)
          end
          system "diff --unified=0 --text #{expected_filename} #{actual_filename} > #{diff}"
          debug_diff = File.read diff
          File.open diff + '.html', 'wb' do |f|
            f.write Highlighter.encode_tokens(CodeRay.scan(debug_diff, :diff),
              :title => "#{self.class.name[/\w+$/]}: #{name}, differences from expected output")
          end
        end
        
        assert(ok, "Scan error: unexpected output".red) if ENV['assert']
        
        print "\b" * 'complete...'.size
        known_issue = expected_filename.sub(/\.expected\..*/, '.known-issue.yaml')
        if !ok && File.exist?(known_issue)
          known_issue = YAML.load_file(known_issue)
          ticket_url = known_issue['ticket_url']
          @known_issue_description = known_issue['description']
          if ticket_url && ticket_url[/(\d+)\/?$/]
            @known_issue_ticket_url = ticket_url
            ticket_info = 'see #' + $1
          else
            ticket_info = 'ticket ?'
          end
          print ticket_info.rjust('complete'.size).red
          print ', '.green
        else
          print 'complete, '.green_or_red(ok)
        end
      else
        File.open(expected_filename, 'wb') { |f| f.write result }
        print "\b" * 'complete...'.size, "new test".blue, ", ".green
        ok = true
      end
      
      return tokens, ok, changed_lines
    end
    
    def identity_test scanner, tokens
      report 'identity' do
        if scanner.instance_of? CodeRay::Scanners[:debug]
          okay = true
        else
          okay = scanner.code == tokens.text
          unless okay
            flunk 'identity test failed!' if ENV['assert']
          end
          okay
        end
      end
    end
    
    Highlighter = CodeRay::Encoders[:html].new(
      :tab_width => 8,
      :line_numbers => :table,
      :wrap => :page,
      :hint => :debug,
      :css => :class,
      :style => :alpha
    )
    
    def highlight_test tokens, name, okay, changed_lines
      
      actual_html = name + '.actual.html'
      title = "Testing #{self.class.name[/\w+$/]}: #{name}"
      report 'highlighting' do
        begin
          highlighted = Highlighter.encode_tokens tokens,
            :highlight_lines => changed_lines,
            :title => title + "[#{'NOT ' unless okay}OKAY]"
        rescue
          raise
          return false
        end
        File.open(actual_html, 'w') { |f| f.write highlighted }
        if okay
          debug, $DEBUG = $DEBUG, false
          FileUtils.copy(actual_html, name + '.expected.html')
          $DEBUG = debug
        end
        true
      end
      
      expected_html = name + '.expected.html'
      if okay
        FileUtils.copy actual_html, expected_html
      else
        expected_raydebug = name + '.expected.raydebug'
        if File.exist? expected_raydebug
          latest_change = File.ctime expected_raydebug
          if !File.exist?(expected_html) || latest_change > File.ctime(expected_html)
            tokens = CodeRay.scan_file expected_raydebug, :debug
            highlighted = Highlighter.encode_tokens tokens,
              :highlight_lines => changed_lines,
              :title => title
            File.open(expected_html, 'w') { |f| f.write highlighted }
          end
        end
      end
      
      true
    end
    
    def report task
      print "#{task}...".yellow
      okay = yield
      print "\b" * "#{task}...".size
      print "#{task}, ".green_or_red(okay)
      okay
    end
  end
  
  class TestSuite
    @suite = Test::Unit::TestSuite.new 'CodeRay::Scanners'
    class << self
      
      def << sub_suite
        @suite << sub_suite
      end
      
      def load_suite name
        begin
          suite = File.join($mydir, name, 'suite.rb')
          require suite
        rescue LoadError
          $stderr.puts <<-ERR
          
      !! Suite #{suite} not found
          
          ERR
          false
        end
      end
      
      def check_env_lang
        for key in %w(only new)
          if ENV[key] && ENV[key][/^(\w+)\.([-\w]+)$/]
            ENV['lang'] = $1
            ENV[key] = $2
          end
        end
      end
      
      def load
        ENV['only'] = ENV['new'] if ENV['new']
        check_env_lang
        subsuite = ARGV.find { |a| break $& if a[/^[^-].*/] } || ENV['lang']
        if subsuite
          load_suite(subsuite) or exit
        else
          Dir[File.join($mydir, '*', '')].sort.each do |suite|
            load_suite File.basename(suite)
          end
        end
      end
      
      def run
        load
        $stdout.sync = true
        require 'test/unit/ui/console/testrunner'
        Test::Unit::UI::Console::TestRunner.run @suite
      end
    end
  end
  
end