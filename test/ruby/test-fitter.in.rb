require 'benchmark'
require 'fits'

N = 100_000

def test s
  puts s
  Benchmark.bm 10 do |bm|
    bm.report 'default' do
      N.times { s =~ /\A\w+\z/ }
    end

    bm.report 'fits?' do
      N.times { s.fits? /\w+/ }
    end

    bm.report 'f' do
      N.times { s =~ /\w+/.f }
    end
   
    re = /\w+/.f

    bm.report 'preparsed' do
      N.times { s =~ re }
    end
  end
  puts
end

a.fits? / bla /x

test 'harmlessline'

test <<EOL
<div style=\"font-size:2px\">Destroy my HTML!
harmlessline
EOL

test <<EOL
harmlessline
harmlesslineharmlessline
<div style=\"font-size:2px\">Destroy my HTML!
harmlessline
EOL

