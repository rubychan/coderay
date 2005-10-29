$: << File.dirname(__FILE__) + '/..'
require 'coderay'
CodeRay::Encoders[:tokens]
CodeRay::Encoders[:html]

require 'test/unit'
include Test::Unit

class CodeRaySuite < TestCase
	
	def self.dir &block
		@dir ||= File.dirname(@file)
		if block
			Dir.chdir @dir, &block
		end
		@dir
	end
	
	def dir &block
		self.class.dir &block
	end
	
	def extension
		'in.' + self.class::EXTENSION
	end

	def lang
		self.class::LANG
	end

	def test_ALL
		CodeRay::Scanners.load lang
		tokenizer = CodeRay.tokens
		highlighter = CodeRay.html
		
		dir do
			for input in Dir["*.#{extension}"]
				name = File.basename(input, ".#{extension}")
				output = name + '.out.tok'
				code = File.read(input)

				computed = tokenizer.encode code, lang
				
				if File.exist? output
					expected = File.read output
					assert_equal(expected, computed)
				else
					File.open(output, 'w') do |f| f.write computed end
					puts "New test: #{output}"
				end

				highlighted = highlighter.highlight_page code, lang
				File.open(name + '.html', 'w') do |f| f.write highlighted end	
			end
		end
	end

end

require 'test/unit/testsuite'
$suite = TestSuite.new

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

if subsuite = ARGV.first
	load_suite(subsuite) or exit
else
	Dir['*/'].each { |suite| load_suite suite }
end

require 'test/unit/ui/console/testrunner'
UI::Console::TestRunner.run $suite
