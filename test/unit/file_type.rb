require 'test/unit'
require File.expand_path('../../lib/assert_warning', __FILE__)

require 'coderay/helpers/file_type'

class FileTypeTests < Test::Unit::TestCase
  
  include CodeRay
  
  def test_fetch
    assert_raise FileType::UnknownFileType do
      FileType.fetch ''
    end
    
    assert_throws :not_found do
      FileType.fetch '.' do
        throw :not_found
      end
    end
    
    assert_equal :default, FileType.fetch('c', :default)
  end
  
  def test_block_supersedes_default_warning
    assert_warning 'Block supersedes default value argument; use either.' do
      FileType.fetch('c', :default) { }
    end
  end
  
  def test_ruby
    assert_equal :ruby, FileType[__FILE__]
    assert_equal :ruby, FileType['test.rb']
    assert_equal :ruby, FileType['test.java.rb']
    assert_equal :java, FileType['test.rb.java']
    assert_equal :ruby, FileType['C:\\Program Files\\x\\y\\c\\test.rbw']
    assert_equal :ruby, FileType['/usr/bin/something/Rakefile']
    assert_equal :ruby, FileType['~/myapp/gem/Rantfile']
    assert_equal :ruby, FileType['./lib/tasks\repository.rake']
    assert_not_equal :ruby, FileType['test_rb']
    assert_not_equal :ruby, FileType['Makefile']
    assert_not_equal :ruby, FileType['set.rb/set']
    assert_not_equal :ruby, FileType['~/projects/blabla/rb']
  end
  
  def test_c
    assert_equal :c, FileType['test.c']
    assert_equal :c, FileType['C:\\Program Files\\x\\y\\c\\test.h']
    assert_not_equal :c, FileType['test_c']
    assert_not_equal :c, FileType['Makefile']
    assert_not_equal :c, FileType['set.h/set']
    assert_not_equal :c, FileType['~/projects/blabla/c']
  end
  
  def test_cpp
    assert_equal :cpp, FileType['test.c++']
    assert_equal :cpp, FileType['test.cxx']
    assert_equal :cpp, FileType['test.hh']
    assert_equal :cpp, FileType['test.hpp']
    assert_equal :cpp, FileType['test.cu']
    assert_equal :cpp, FileType['test.C']
    assert_not_equal :cpp, FileType['test.c']
    assert_not_equal :cpp, FileType['test.h']
  end
  
  def test_html
    assert_equal :html, FileType['test.htm']
    assert_equal :html, FileType['test.xhtml']
    assert_equal :html, FileType['test.html.xhtml']
    assert_equal :erb, FileType['_form.rhtml']
    assert_equal :erb, FileType['_form.html.erb']
  end
  
  def test_yaml
    assert_equal :yaml, FileType['test.yml']
    assert_equal :yaml, FileType['test.yaml']
    assert_equal :yaml, FileType['my.html.yaml']
    assert_not_equal :yaml, FileType['YAML']
  end
  
  def test_pathname
    require 'pathname'
    pn = Pathname.new 'test.rb'
    assert_equal :ruby, FileType[pn]
    dir = Pathname.new '/etc/var/blubb'
    assert_equal :ruby, FileType[dir + pn]
    assert_equal :cpp, FileType[dir + 'test.cpp']
  end
  
  def test_no_shebang
    dir = './test'
    if File.directory? dir
      Dir.chdir dir do
        assert_equal :c, FileType['test.c']
      end
    end
  end
  
  def test_shebang_empty_file
    require 'tmpdir'
    tmpfile = File.join(Dir.tmpdir, 'bla')
    File.open(tmpfile, 'w') { }  # touch
    assert_equal nil, FileType[tmpfile, true]
  end
  
  def test_shebang_no_file
    assert_equal nil, FileType['i do not exist', true]
  end
  
  def test_shebang
    require 'tmpdir'
    tmpfile = File.join(Dir.tmpdir, 'bla')
    File.open(tmpfile, 'w') { |f| f.puts '#!/usr/bin/env ruby' }
    assert_equal :ruby, FileType[tmpfile, true]
  end
  
end
