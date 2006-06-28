$mydir = File.dirname(__FILE__)
$:.unshift $mydir + '/../lib/'

$VERBOSE = true

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
		self.class.dir(&block)
	end
	
	def extension
		'in.' + self.class::EXTENSION
	end

	def lang
		self.class::LANG
	end

	def test_ALL
		puts
		puts "    >> Running #{self.class.name} <<"
		puts
		scanner = CodeRay::Scanners[lang].new
		tokenizer = CodeRay::Encoders[:debug].new
		highlighter = CodeRay::Encoders[:html].new(
			:tab_width => 2,
			:line_numbers => :table,
			:wrap => :page,
			:hint => :debug,
			:css => :class
		)
		
		dir do
			for input in Dir["*.#{extension}"]
				puts "testing #{input}..."
				name = File.basename(input, ".#{extension}")
				output = name + '.out.' + tokenizer.file_extension
				code = File.open(input, 'rb') { |f| break f.read }

				scanner.string = code
				tokens = scanner.tokens
				result = tokenizer.encode_tokens tokens
				highlighted = highlighter.encode_tokens tokens
				
				File.open(name + '.html', 'w') do |f| f.write highlighted end	

				if File.exist? output
					expected = File.read output
					ok = expected == result
					computed = output.sub('.out.', '.computed.')
					unless ok
						File.open(computed, 'w') { |f| f.write result }
						print `gvimdiff #{output} #{computed}` if ENV['diff']
					end
					assert(ok, "Scan error: #{computed} != #{output}") unless ENV['diff']
				else
					File.open(output, 'w') do |f| f.write result end
					puts "New test: #{output}"
				end

			end
		end
	end

end

require 'test/unit/testsuite'
$suite = TestSuite.new

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

if subsuite = ARGV.find { |a| break $1 if a[/^([^-].*)/] } || ENV['scannerlang']
	load_suite(subsuite) or exit
else
	Dir[File.join($mydir, '*', '')].each { |suite| load_suite File.basename(suite) }
end

if ARGV.include? '-f'
	require 'test/unit/ui/fox/testrunner'
	UI::Fox::TestRunner.run $suite
else
	require 'test/unit/ui/console/testrunner'
	UI::Console::TestRunner.run $suite
end
