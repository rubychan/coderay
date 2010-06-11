require 'test/unit'
require 'pathname'

MYDIR = File.dirname(__FILE__)

$:.unshift 'lib'
require 'coderay'
puts "Running basic CodeRay #{CodeRay::VERSION} executable tests..."

class TestCodeRayExecutable < Test::Unit::TestCase
  
  ruby = `ps -c #$$`[/\w+\Z/]
  ruby = 'jruby' if ruby == 'java'
  
  ROOT_DIR = Pathname.new(File.dirname(__FILE__)) + '..' + '..'
  EXECUTABLE = ROOT_DIR + 'bin' + 'coderay'
  EXE_COMMAND = '%s -wI%s %s'% [
    ruby,  # calling Ruby process command
    ROOT_DIR + 'lib',  # library dir
    EXECUTABLE
  ]
  
  def coderay args
    command = "#{EXE_COMMAND} #{args}"
    # puts command
    `#{command}`
  end
  
  def test_simple
    assert_nothing_raised { coderay('') }
  end
  
  VERSION_PATTERN = /CodeRay \d\.\d\.\d/
  def test_version
    assert_match(VERSION_PATTERN, coderay(''))
    # assert_match(VERSION_PATTERN, coderay('--version'))
    # assert_match(VERSION_PATTERN, coderay('-v'))
  end
  
  HELP_PATTERN = /Usage:/
  def test_help
    assert_match(HELP_PATTERN, coderay(''))
    # assert_match(HELP_PATTERN, coderay('--help'))
    # assert_match(HELP_PATTERN, coderay('-h'))
  end
  
end