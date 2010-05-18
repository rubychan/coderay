($:.unshift '../..'; require 'coderay') unless defined? CodeRay
module CodeRay
module Encoders
  
  load :token_kind_filter
  
  # A simple Filter that removes all tokens of the :comment kind.
  # 
  # Alias: +remove_comments+
  # 
  # Usage:
  #  CodeRay.scan('print # foo', :ruby).comment_filter.text
  #  #-> "print "
  # 
  # See also: TokenKindFilter, LinesOfCode
  class CommentFilter < TokenKindFilter
    
    register_for :comment_filter
    
    DEFAULT_OPTIONS = superclass::DEFAULT_OPTIONS.merge \
      :exclude => [:comment, :docstring]
    
  end
  
end
end

if $0 == __FILE__
  $VERBOSE = true
  $: << File.join(File.dirname(__FILE__), '..')
  eval DATA.read, nil, $0, __LINE__ + 4
end

__END__
require 'test/unit'

class CommentFilterTest < Test::Unit::TestCase
  
  def test_filtering_comments
    tokens = CodeRay.scan <<-RUBY, :ruby
#!/usr/bin/env ruby
# a minimal Ruby program
puts "Hello world!"
    RUBY
    assert_equal <<-RUBY_FILTERED, tokens.comment_filter.text
#!/usr/bin/env ruby

puts "Hello world!"
    RUBY_FILTERED
  end
  
  def test_filtering_docstrings
    tokens = CodeRay.scan <<-PYTHON, :python
'''
Assuming this is file mymodule.py then this string, being the
first statement in the file will become the mymodule modules
docstring when the file is imported
'''

class Myclass():
    """
    The class's docstring
    """

    def mymethod(self):
        '''The method's docstring'''

def myfunction():
    """The function's docstring"""
    PYTHON
    assert_equal <<-PYTHON_FILTERED.chomp, tokens.comment_filter.text


class Myclass():
    

    def mymethod(self):
        

def myfunction():
    

PYTHON_FILTERED
  end
  
end