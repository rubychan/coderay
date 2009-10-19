require "benchmark"
require "strscan"

TESTS = 2_000_000
S = 'begin ' * TESTS
r = /begin /

len = nil
Benchmark.bm 20 do |results|
  results.report 'string' do
    s = StringScanner.new S
    a = []
    while matched = s.scan(r)
      a << [matched, :test]
    end
  end
  results.report 'length' do
    s = StringScanner.new S
    a = []
    while len = s.skip(r)
      a << [len, :test]
    end
  end
  results.report 'two arrays' do
    s = StringScanner.new S
    a = []
    b = []
    while matched = s.scan(r)
      a << len
      b << :test
    end
  end
end