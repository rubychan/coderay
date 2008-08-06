mydir = File.dirname(__FILE__)
require File.join(mydir, 'coderay_suite')

CodeRay::TestSuite.run
