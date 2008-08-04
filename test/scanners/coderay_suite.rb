require 'benchmark'
require 'ftools'

$mydir = File.dirname(__FILE__)
$:.unshift File.join($mydir, '..', '..', 'lib')

require 'coderay'

debug, $DEBUG = $DEBUG, false

require 'term/ansicolor' unless ENV['nocolor']

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
$DEBUG = debug

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
      DEFAULT_MAX = 1024
    else
      MAX_CODE_SIZE_TO_HIGHLIGHT = 5_000_000
      MAX_CODE_SIZE_TO_TEST = 5_000_000
      DEFAULT_MAX = 128
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
        @lang ||= name.downcase.to_sym
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
      puts '    >> Testing '.magenta + self.class.name.cyan +
        ' scanner <<'.magenta
      puts
      
      time_for_lang = Benchmark.realtime do
        scanner = CodeRay::Scanners[self.class.lang].new
        max = ENV.fetch('max', DEFAULT_MAX).to_i
        
        random_test scanner, max unless ENV['norandom'] || ENV['only']
        
        unless ENV['noexamples']
          examples_test scanner, max
        end
      end
      
      puts 'Finished in '.green + '%0.2fs'.white % time_for_lang + '.'.green
    end
    
    def examples_test scanner, max
      self.class.dir do
        extension = 'in.' + self.class.extension
        for example_filename in Dir["*.#{extension}"]
          name = File.basename(example_filename, ".#{extension}")
          next if ENV['lang'] && ENV['only'] && ENV['only'] != name
          print name_and_size = ('%15s'.cyan + ' %6.1fK: '.yellow) %
            [ name, File.size(example_filename) / 1024.0 ]
          time_for_file = Benchmark.realtime do
            example_test example_filename, name, scanner, max
          end
          print 'finished in '.green + '%0.2fs'.white % time_for_file
          puts '.'.green
        end
      end
    end
    
    def example_test example_filename, name, scanner, max
      if File.size(example_filename) > MAX_CODE_SIZE_TO_TEST and not ENV['only']
        print 'too big, '
        return
      end
      code = File.open(example_filename, 'rb') { |f| break f.read }
      
      incremental_test scanner, code, max unless ENV['noincremental']
      
      unless ENV['noshuffled'] or code.size < [0].pack('Q').size
        shuffled_test scanner, code, max
      else
        print '-skipped- '.concealed
      end
      
      tokens, ok = complete_test scanner, code, name
      
      identity_test scanner, tokens
      
      unless ENV['nohighlighting'] or (code.size > MAX_CODE_SIZE_TO_HIGHLIGHT and not ENV['only'])
        highlight_test tokens, name, ok
      else
        print '-- skipped -- '.concealed
      end
    end
    
    def random_test scanner, max
      print "Random test...".yellow
      okay = true
      for size in (0..max).progress
        srand size + 17
        scanner.string = Array.new(size) { rand 256 }.pack 'c*'
        begin
          scanner.tokenize
        rescue
          flunk "Random test failed at #{size} #{RUBY_VERSION < '1.9' ? 'bytes' : 'chars'}!" unless ENV['noassert']
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
            flunk "Incremental test failed at #{size} #{RUBY_VERSION < '1.9' ? 'bytes' : 'chars'}!" unless ENV['noassert']
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
            flunk 'shuffle test failed!' unless ENV['noassert']
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
      tokens = scanner.tokens
      result = Tokenizer.encode_tokens tokens
      
      if File.exist?(expected_filename) && !(ENV['lang'] && ENV['new'] && name == ENV['new'])
        expected = File.open(expected_filename, 'rb') { |f| break f.read }
        ok = expected == result
        actual_filename = expected_filename.sub('.expected.', '.actual.')
        unless ok
          File.open(actual_filename, 'wb') { |f| f.write result }
          if ENV['diff'] or ENV['diffed']
            diff = expected_filename.sub(/\.expected\..*/, '.debug.diff')
            system "diff --unified=0 --text #{expected_filename} #{actual_filename} > #{diff}"
            system "EDITOR #{diff}" if ENV['diffed']
          end
        end
        unless ENV['noassert']
          assert(ok, "Scan error: unexpected output".red)
        end
        print "\b" * 'complete...'.size
        print 'complete, '.green_or_red(ok)
      else
        File.open(expected_filename, 'wb') { |f| f.write result }
        print "\b" * 'complete...'.size, "new test, ".blue
        ok = true
      end
      
      return tokens, ok
    end
    
    def identity_test scanner, tokens
      report 'identity' do
        if scanner.instance_of? CodeRay::Scanners[:debug]
          okay = true
        else
          okay = scanner.code == tokens.text
          unless okay
            flunk 'identity test failed!' unless ENV['noassert']
          end
          okay
        end
      end
    end
    
    Highlighter = CodeRay::Encoders[:html].new(
      :tab_width => 2,
      :line_numbers => :table,
      :wrap => :page,
      :hint => :debug,
      :css => :class
    )
    
    def highlight_test tokens, name, okay
      report 'highlighting' do
        begin
          highlighted = Highlighter.encode_tokens tokens
        rescue
          flunk 'highlighting test failed!' unless ENV['noassert']
          return
        end
        File.open(name + '.actual.html', 'w') { |f| f.write highlighted }
        File.copy(name + '.actual.html', name + '.expected.html') if okay
        true
      end
    end
    
    def report task
      print "#{task}...".yellow
      okay = yield
      print "\b" * "#{task}...".size
      print "#{task}, ".green_or_red(okay)
      okay
    end
  end
  
  require 'test/unit/testsuite'
  
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
          if ENV[key] && ENV[key][/^(\w+)\.([\w_]+)$/]
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
        $VERBOSE = true
        $stdout.sync = true
        require 'test/unit/ui/console/testrunner'
        Test::Unit::UI::Console::TestRunner.run @suite
      end
    end
  end
  
end