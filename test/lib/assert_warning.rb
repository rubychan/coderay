class Test::Unit::TestCase
  
  def assert_warning expected_warning
    require 'stringio'
    oldstderr = $stderr
    $stderr = StringIO.new
    yield
    $stderr.rewind
    given_warning = $stderr.read.chomp
    assert_equal expected_warning, given_warning
  ensure
    $stderr = oldstderr
  end
  
end
