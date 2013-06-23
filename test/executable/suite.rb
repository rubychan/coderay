require 'test/unit'
require 'rubygems' unless defined? Gem
require 'shoulda-context'

require 'pathname'
require 'json'

$:.unshift File.expand_path('../../../lib', __FILE__)
require 'coderay'

puts "Running CodeRay #{CodeRay::VERSION} executable tests..."

class TestCodeRayExecutable < Test::Unit::TestCase
  
  ROOT_DIR = Pathname.new(File.dirname(__FILE__)) + '..' + '..'
  EXECUTABLE = ROOT_DIR + 'bin' + 'coderay'
  RUBY_COMMAND = 'ruby'
  EXE_COMMAND =
    if RUBY_PLATFORM === 'java' && `ruby --ng -e '' 2> /dev/null` && $?.success?
      # use Nailgun
      "#{RUBY_COMMAND}--ng -I%s %s"
    else
      "#{RUBY_COMMAND} -I%s %s"
    end % [ROOT_DIR + 'lib', EXECUTABLE]
  
  def coderay args, options = {}
    if options[:fake_tty]
      command = "#{EXE_COMMAND} #{args} --tty"
    else
      command = "#{EXE_COMMAND} #{args}"
    end
    
    puts command if $DEBUG
    
    if options[:input]
      output = IO.popen "#{command} 2>&1", "r+" do |io|
        io.write options[:input]
        io.close_write
        io.read
      end
    else
      output = `#{command} 2>&1`
    end
    
    if output[EXECUTABLE.to_s]
      raise output
    else
      output
    end
  end
  
  context 'a simple call with no arguments' do
    should 'work' do
      assert_nothing_raised { coderay('') }
    end
    should 'print version and help' do
      assert_match(/CodeRay #{CodeRay::VERSION}/, coderay(''))
      assert_match(/usage:/, coderay(''))
    end
  end
  
  context 'version' do
    should 'be printed with -v' do
      assert_match(/\ACodeRay #{CodeRay::VERSION}\Z/, coderay('-v'))
    end
    should 'be printed with --version' do
      assert_match(/\ACodeRay #{CodeRay::VERSION}\Z/, coderay('--version'))
    end
  end
  
  context 'help' do
    should 'be printed with -h' do
      assert_match(/^usage:/, coderay('-h'))
    end
    should 'be printed with --help' do
      assert_match(/^usage:/, coderay('--help'))
    end
    should 'be printed with subcommand help' do
      assert_match(/^usage:/, coderay('help'))
    end
  end
  
  context 'commands' do
    should 'be printed with subcommand commands' do
      assert_match(/^ +help/, coderay('commands'))
      assert_match(/^ +version/, coderay('commands'))
    end
  end
  
  context 'highlighting a file to the terminal' do
    source_file = ROOT_DIR + 'test/executable/source.py'
    
    source = File.read source_file
    
    ansi_seq = /\e\[[0-9;]+m/
    
    should 'not throw an error' do
      assert_nothing_raised { coderay(source_file, :fake_tty => true) }
    end
    should 'output its contents to stdout' do
      target = coderay(source_file, :fake_tty => true)
      assert_equal source, target.chomp.gsub(ansi_seq, '')
    end
    should 'output ANSI-colored text' do
      target = coderay(source_file, :fake_tty => true)
      assert_not_equal source, target.chomp
      assert_equal 6, target.scan(ansi_seq).size
    end
  end
  
  context 'highlighting a file into a pipe (source.rb -html > source.rb.html)' do
    source_file = ROOT_DIR + 'test/executable/source.rb'
    target_file = "#{source_file}.html"
    command = "#{source_file} -html > #{target_file}"
    
    source = File.read source_file
    
    pre = %r{<td class="code"><pre>(.*?)</pre>}m
    tag = /<[^>]*>/
    
    should 'not throw an error' do
      assert_nothing_raised { coderay(command) }
    end
    should 'output its contents to the pipe' do
      coderay(command)
      target = File.read(target_file)
      if target = target[pre, 1]
        assert_equal source, target.gsub(tag, '').strip
      else
        flunk "target code has no <pre> tag: #{target}"
      end
    end
    should 'output valid HTML' do
      coderay(command)
      target = File.read(target_file)
      assert_not_equal source, target[pre, 1]
      assert_equal 6, target[pre, 1].scan(tag).size
      assert_match %r{\A<!DOCTYPE html>\n<html>\n<head>}, target
    end
  end
  
  context 'highlighting a file into another file (source.rb source.rb.json)' do
    source_file = ROOT_DIR + 'test/executable/source.rb'
    target_file = "#{source_file}.json"
    command = "#{source_file} #{target_file}"
    
    source = File.read source_file
    
    text = /"text":"([^"]*)"/
    
    should 'not throw an error' do
      assert_nothing_raised { coderay(command) }
    end
    should 'output its contents to the file' do
      coderay(command)
      target = File.read(target_file)
      assert_equal source, target.scan(text).join
    end
    should 'output JSON' do
      coderay(command)
      target = File.read(target_file)
      assert_not_equal source, target
      assert_equal 6, target.scan(text).size
    end
  end
  
  context 'highlighting a file without explicit input type (source.py)' do
    source_file = ROOT_DIR + 'test/executable/source.py'
    command = "#{source_file} -html"
    
    source = File.read source_file
    
    pre = %r{<td class="code"><pre>(.*?)</pre>}m
    tag_class = /<span class="([^>"]*)"?[^>]*>/
    
    should 'respect the file extension and highlight the input as Python' do
      target = coderay(command)
      assert_equal %w(keyword class keyword), target[pre, 1].scan(tag_class).flatten
    end
  end
  
  context 'highlighting a file with explicit input type (-ruby source.py)' do
    source_file = ROOT_DIR + 'test/executable/source.py'
    command = "-ruby #{source_file} -html"
    
    source = File.read source_file
    
    pre = %r{<td class="code"><pre>(.*?)</pre>}m
    tag_class = /<span class="([^>"]*)"?[^>]*>/
    
    should 'ignore the file extension and highlight the input as Ruby' do
      target = coderay(command)
      assert_equal %w(keyword class), target[pre, 1].scan(tag_class).flatten
    end
  end
  
  context 'highlighting a file with explicit input and output type (-ruby source.py -span)' do
    source_file = ROOT_DIR + 'test/executable/source.py'
    command = "-ruby #{source_file} -span"
    
    source = File.read source_file
    
    span_tags = /<\/?span[^>]*>/
    
    should 'just respect the output type and include span tags' do
      target = coderay(command)
      assert_equal source, target.chomp.gsub(span_tags, '')
    end
  end
  
  context 'the LOC counter' do
    source_file = ROOT_DIR + 'test/executable/source_with_comments.rb'
    command = "-ruby -loc"
    
    should 'work' do
      output = coderay(command, :input => <<-CODE)
# test
=begin
=end
test
      CODE
      assert_equal "1\n", output
    end
  end
  
end
