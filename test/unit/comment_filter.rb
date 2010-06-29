require 'test/unit'
require 'coderay'

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