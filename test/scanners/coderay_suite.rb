require 'benchmark'

$mydir = File.dirname(__FILE__)
$:.unshift File.join($mydir, '..', '..', 'lib')

require 'coderay'

debug, $DEBUG = $DEBUG, false
# Try to load Term::ANSIColor...
begin
  require 'term-ansicolor'
rescue LoadError
  begin
    require 'rubygems'
    require_gem 'term-ansicolor'
  rescue LoadError
    # ignore
  end
end unless ENV['nocolor']

if defined? Term::ANSIColor
  class String
    include Term::ANSIColor
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
      MAX_CODE_SIZE_TO_HIGHLIGHT = 200_000
      MAX_CODE_SIZE_TO_TEST = 1_000_000
      DEFAULT_MAX = 512
    else
      MAX_CODE_SIZE_TO_HIGHLIGHT = 20_000
      MAX_CODE_SIZE_TO_TEST = 100_000
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
          @extension ||= lang.to_s
        end
      end
    end
    
    # Create only once, for speed
    Tokenizer = CodeRay::Encoders[:debug].new
    Highlighter = CodeRay::Encoders[:html].new(
      :tab_width => 2,
      :line_numbers => :inline,
      :wrap => :page,
      :hint => :debug,
      :css => :class
    )
    
    def test_ALL
      puts
      puts '    >> Testing '.magenta + self.class.name.cyan +
        ' scanner <<'.magenta
      puts
      
      time_for_lang = Benchmark.realtime do
        scanner = CodeRay::Scanners[self.class.lang].new
        max = ENV.fetch('max', DEFAULT_MAX).to_i
        
        random_test scanner, max unless ENV['norandom']
        
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
          next if ENV['example'] and ENV['example'] != name
          print name_and_size = ('%15s'.cyan + ' %4.0fK: '.yellow) %
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
      if File.size(example_filename) > MAX_CODE_SIZE_TO_TEST and not ENV['example']
        print 'too big. '
        return
      end
      code = File.open(example_filename, 'rb') { |f| break f.read }
    
      incremental_test scanner, code, max unless ENV['noincremental']

      unless ENV['noshuffled'] or code.size < [0].pack('Q').size
        shuffled_test scanner, code, max
      else
        print '-skipped- '.concealed
      end

      tokens = compare_test scanner, code, name
      
      identity_test scanner, tokens
      
      unless ENV['nohl'] or code.size > MAX_CODE_SIZE_TO_HIGHLIGHT
        highlight_test tokens, name
      else
        print '-- skipped -- '.concealed
      end
    end
    
    def random_test scanner, max
      print "Random test...".red
      for size in (0..max).progress
        srand size + 17
        scanner.string = Array.new(size) { rand 256 }.pack 'c*'
        scanner.tokenize
      end
      print "\b\b\b"
      puts ' - finished'.green
    end
    
    def incremental_test scanner, code, max
      print 'incremental...'.red
      for size in (0..max).progress
        break if size > code.size
        scanner.string = code[0,size]
        scanner.tokenize
      end
      print "\b\b\b"
      print ', '.red
    end

    def shuffled_test scanner, code, max
      print 'shuffled...'.red
      code_bits = code[0,max].unpack('Q*')  # split into quadwords...
      for i in (0..max / 4).progress
        srand i
        code_bits.shuffle!                     # ...mix...
        scanner.string = code_bits.pack('Q*')  # ...and join again
        scanner.tokenize
      end

      # highlighted = highlighter.encode_tokens scanner.tokenize
      # File.open(name + '.shuffled.html', 'w') { |f| f.write highlighted }
      print "\b\b\b"
      print ', '.red
    end
    
    def compare_test scanner, code, name
      print 'complete...'.red
      expected_filename = name + '.expected.' + Tokenizer.file_extension
      scanner.string = code
      tokens = scanner.tokens
      result = Tokenizer.encode_tokens tokens

      if File.exist? expected_filename
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
      else
        print "\b" * 'complete...'.size, "new test..."
        File.open(expected_filename, 'wb') { |f| f.write result }
      end
      
      print "\b\b\b"
      print ', '.red
      
      tokens
    end
    
    def identity_test scanner, tokens
      print 'identity...'.red
      unless scanner.instance_of? CodeRay::Scanners[:debug]
        assert_equal scanner.code, tokens.text
      end
      print "\b\b\b"
      print ', '.red
    end
    
    def highlight_test tokens, name
      print 'highlighting, '.red
      highlighted = Highlighter.encode_tokens tokens
      File.open(name + '.actual.html', 'w') { |f| f.write highlighted }      
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

      def load
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