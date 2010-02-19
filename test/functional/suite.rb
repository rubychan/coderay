require 'test/unit'

require 'pathname'
MYDIR = Pathname.new(__FILE__).dirname
LIBDIR = Pathname.new(MYDIR).join('..', '..', 'lib').cleanpath.to_s
$LOAD_PATH.unshift MYDIR, LIBDIR

require 'coderay'

if $0 == __FILE__
  suite = %w(basic load_plugin_scanner word_list)
  for test_case in suite
    load MYDIR + (test_case + '.rb')
  end
end