require 'test/unit'
require 'pathname'

MYDIR = File.dirname(__FILE__)
LIBDIR = Pathname.new(MYDIR).join('..', '..', 'lib').cleanpath.to_s
$LOAD_PATH.unshift MYDIR, LIBDIR

require 'basic'
require 'word_list'
