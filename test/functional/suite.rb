require 'test/unit'
$:.unshift 'lib'
require 'coderay'

MYDIR = File.dirname(__FILE__)
suite = Dir[File.join(MYDIR, '*.rb')].
  map { |tc| File.basename(tc).sub(/\.rb$/, '') } - %w'suite for_redcloth'

puts "Running basic CodeRay #{CodeRay::VERSION} tests: #{suite.join(', ')}"

for test_case in suite
  load File.join(MYDIR, test_case + '.rb')
end
