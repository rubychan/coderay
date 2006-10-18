$mydir = File.dirname(__FILE__)
$:.unshift File.join($mydir, '..', '..', 'lib')

require 'coderay'

$stdout.sync = true

# from Ruby Facets (http://facets.rubyforge.org/)
class Array
  def shuffle!
    s = size
    each_index do |j|
      i = ::Kernel.rand(s-j)
      self[j], self[j+i] = at(j+i), at(j) unless i.zero?
    end
    self
  end
end unless [].respond_to? :shuffle!

module CodeRay

  require 'test/unit'

  class TestCase < Test::Unit::TestCase

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

    def extension
      @extension ||= 'in.' + self.class.extension
    end

    def test_ALL
      puts
      puts "    >> Running #{self.class.name} <<"
      puts
      scanner = CodeRay::Scanners[self.class.lang].new
      tokenizer = CodeRay::Encoders[:debug].new
      highlighter = CodeRay::Encoders[:html].new(
        :tab_width => 2,
        :line_numbers => :inline,
        :wrap => :page,
        :hint => :debug,
        :css => :class
      )
      
      max = ENV.fetch('max', 500).to_i
      unless ENV['norandom']
        print "Random test"
        if ENV['showprogress']
          print ': '
          progress = ''
        end
        for size in 0..max
          if ENV['showprogress']
            print "\b" * progress.size
            progress = '(%d)' % size
            print progress
          end
          srand size + 17
          scanner.string = Array.new(size) { rand 256 }.pack 'c*'
          scanner.tokenize
        end
        puts ', finished.'
      end

      self.class.dir do
        for input in Dir["*.#{extension}"]
          next if ENV['testonly'] and ENV['testonly'] != File.basename(input, ".#{extension}")
          print "testing #{input}: "
          name = File.basename(input, ".#{extension}")
          expected_filename = name + '.expected.' + tokenizer.file_extension
          code = File.open(input, 'rb') { |f| break f.read }
          
          unless ENV['noincremental']
            print 'incremental'
            if ENV['showprogress']
              print ': ' 
              progress = ''
            end
            for size in 0..max
              break if size > code.size
              if ENV['showprogress']
                print "\b" * progress.size
                progress = '(%d)' % size
                print progress
              end
              scanner.string = code[0,size]
              scanner.tokenize
            end
            print ', '
          end

          unless ENV['noshuffled'] or code.size < [0].pack('Q').size
            print 'shuffled'
            if ENV['showprogress']
              print ': ' 
              progress = ''
            end
            code_bits = code[0,max].unpack('Q*')     # split into quadwords...
            (max / 4).times do |i|
              if ENV['showprogress']
                print "\b" * progress.size
                progress = '(%d)' % i
                print progress
              end
              srand i
              code_bits.shuffle!                     # ...mix...
              scanner.string = code_bits.pack('Q*')  # ...and join again
              scanner.tokenize
            end
            
            # highlighted = highlighter.encode_tokens scanner.tokenize
            # File.open(name + '.shuffled.html', 'w') { |f| f.write highlighted }
            print ', '
          end

          print 'complete, '
          scanner.string = code
          tokens = scanner.tokens
          result = tokenizer.encode_tokens tokens

          if File.exist? expected_filename
            expected = File.open(expected_filename, 'rb') { |f| break f.read }
            ok = expected == result
            actual_filename = expected_filename.sub('.expected.', '.actual.')
            unless ok
              File.open(actual_filename, 'wb') { |f| f.write result }
              if ENV['diff']
                diff = expected_filename.sub(/\.expected\..*/, '.diff')
                system "diff #{expected_filename} #{actual_filename} > #{diff}"
                system "EDITOR #{diff}"
              end
            end
            unless ENV['diff'] or ENV['noassert']
              assert(ok, "Scan error: unexpected output")
            end
          else
            File.open(expected_filename, 'wb') { |f| f.write result }
            puts "New test: #{expected_filename}"
          end

          print 'highlighting, '
          highlighted = highlighter.encode_tokens tokens
          File.open(name + '.actual.html', 'w') { |f| f.write highlighted }

          puts 'finished.'
        end
      end unless ENV['noexamples']
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
        if subsuite = ARGV.find { |a| break $1 if a[/^([^-].*)/] } || ENV['lang']
          load_suite(subsuite) or exit
        else
          Dir[File.join($mydir, '*', '')].sort.each { |suite| load_suite File.basename(suite) }
        end
      end

      def run
        load
        $VERBOSE = true
        if ARGV.include? '-f'
          require 'test/unit/ui/fox/testrunner'
          Test::Unit::UI::Fox::TestRunner
        else
          require 'test/unit/ui/console/testrunner'
          Test::Unit::UI::Console::TestRunner
        end.run @suite
      end
    end
  end

end