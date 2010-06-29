require 'test/unit'
$:.unshift 'lib'

MYDIR = File.dirname(__FILE__)
suite = Dir[File.join(MYDIR, '*.rb')].
  map { |tc| File.basename(tc).sub(/\.rb$/, '') } - %w'suite vhdl'

puts "Running CodeRay unit tests: #{suite.join(', ')}"

helpers = %w(file_type word_list tokens)
for test_case in helpers + (suite - helpers)
  load File.join(MYDIR, test_case + '.rb')
end
