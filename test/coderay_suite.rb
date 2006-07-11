$mydir = File.dirname __FILE__
$:.unshift File.join($mydir, '..', 'lib')

require 'coderay'

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

      self.class.dir do
        for input in Dir["*.#{extension}"]
          next if ENV['testonly'] and ENV['testonly'] != File.basename(input, ".#{extension}")
          print "testing #{input}: "
          name = File.basename(input, ".#{extension}")
          output = name + '.out.' + tokenizer.file_extension
          code = File.open(input, 'rb') { |f| break f.read }

          unless ENV['noincremental']
            print 'incremental, '
            for size in 0..[code.size, 300].min
              print size, '.' if ENV['showprogress']
              scanner.string = code[0,size]
              scanner.tokenize
            end
          end

          print 'complete, '
          scanner.string = code
          tokens = scanner.tokens
          result = tokenizer.encode_tokens tokens

          if File.exist? output
            expected = File.open(output, 'rb') { |f| break f.read }
            ok = expected == result
            computed = output.sub('.out.', '.computed.')
            unless ok
              File.open(computed, 'wb') { |f| f.write result }
              print `gvimdiff #{output} #{computed}` if ENV['diff']
            end
            assert(ok, "Scan error: #{computed} != #{output}") unless ENV['diff']
          else
            File.open(output, 'wb') do |f| f.write result end
            puts "New test: #{output}"
          end

          print 'highlighting, '
          highlighted = highlighter.encode_tokens tokens
          File.open(name + '.html', 'w') { |f| f.write highlighted }

          puts 'finished.'
        end
      end
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
        if subsuite = ARGV.find { |a| break $1 if a[/^([^-].*)/] } || ENV['scannerlang']
          load_suite(subsuite) or exit
        else
          Dir[File.join($mydir, '*', '')].each { |suite| load_suite File.basename(suite) }
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
