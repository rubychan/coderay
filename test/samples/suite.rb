mydir = File.dirname(__FILE__)
$:.unshift mydir + '/../../lib/'

$VERBOSE = true

require 'test/unit'
include Test::Unit

class CodeRaySuite < TestCase

  def self.dir &block
    @dir ||= File.dirname(__FILE__)
    if block
      Dir.chdir @dir, &block
    end
    @dir
  end

  def dir &block
    self.class.dir(&block)
  end

  def test_ALL
    dir do
      for input in Dir["*.rb"] - %w(server.rb stream.rb suite.rb)
        next if input[/^load_/]
        puts "[ testing #{input}... ]"
        name = File.basename(input, ".rb")
        output = name + '.expected'
        code = File.open(input, 'rb') { |f| break f.read }
        
        result = `ruby -wI../../lib #{input}`
        
        diff = output.sub '.expected', '.diff'
        File.delete diff if File.exist? diff
        computed = output.sub '.expected', '.actual'
        if File.exist? output
          expected = File.read output
          ok = expected == result
          unless ok
            File.open(computed, 'w') { |f| f.write result }
            `diff #{output} #{computed} > #{diff}`
            puts "Test failed; output written to #{diff}."
          end
          assert(ok, "Output error: #{computed} != #{output}")
        else
          File.open(output, 'w') do |f| f.write result end
          puts "New test: #{output}"
        end

      end
    end
  end

end

require 'test/unit/testsuite'
$suite = TestSuite.new 'CodeRay Demos Test'
$suite << CodeRaySuite.suite

def load_suite name
  begin
    require name + '/suite.rb'
  rescue LoadError
    $stderr.puts <<-ERR

!! Folder #{File.split(__FILE__).first + '/' + name} not found

    ERR
    false
  end
end

if subsuite = ARGV.find { |a| break $1 if a[/^([^-].*)/] }
  load_suite(subsuite) or exit
else
  Dir[mydir + '/*/'].each { |suite| load_suite suite }
end

if ARGV.include? '-f'
  require 'test/unit/ui/fox/testrunner'
  UI::Fox::TestRunner.run $suite
else
  require 'test/unit/ui/console/testrunner'
  UI::Console::TestRunner.run $suite
end
