require 'pathname'
mydir = Pathname.new(__FILE__).dirname.expand_path

require mydir + 'coderay_suite'

CodeRay::TestSuite.run
