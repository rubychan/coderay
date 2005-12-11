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
		CodeRay::Scanners.load lang
		tokenizer = CodeRay::Encoders[:debug].new
		highlighter = CodeRay::Encoders[:html].new(
			:tab_width => 2,
			:line_numbers => :table,
			:wrap => :page,
			:hint => :debug
		)
		
		dir do
			for input in Dir["*.#{extension}"]
				puts "testing #{input}..."
				name = File.basename(input, ".#{extension}")
				output = name + '.out.' + tokenizer.file_extension
				code = File.open(input, 'rb') { |f| break f.read }

				tokens = CodeRay.scan code, lang
				result = tokenizer.encode_tokens tokens
				highlighted = highlighter.encode_tokens tokens
				
				File.open(name + '.html', 'w') do |f| f.write highlighted end	

				if File.exist? output
					expected = File.read output
					ok = expected == result
					computed = output.sub('.out.', '.computed.')
					unless ok
						File.open(computed, 'w') { |f| f.write result }
						print `gvimdiff #{output} #{computed}` if $DEBUG
					end
					assert(ok, "Scan error: #{computed} != #{output}") unless $DEBUG
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
		require name + '/suite.rb'
	rescue LoadError
		$stderr.puts <<-ERR

!! Folder #{File.join $mydir, name} not found
		
		ERR
		false
	end
end

if subsuite = ARGV.find { |a| break $1 if a[/^([^-].*)/] }
	load_suite(subsuite) or exit
else
	Dir[File.join($mydir, '*', '')].each { |suite| load_suite suite }
end

if ARGV.include? '-f'
	require 'test/unit/ui/fox/testrunner'
	UI::Fox::TestRunner.run $suite
else
	require 'test/unit/ui/console/testrunner'
	UI::Console::TestRunner.run $suite
end
