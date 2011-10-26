require 'rubygems'
require 'gruff'

g = Gruff::Pie.new
g.title = 'CodeRay Scanner tests'

data = {}
other = 0
DATA.read.scan(/>> Testing (.*?) scanner <<.*?^Finished in ([\d.]+)s/m) do |lang, secs|
  secs = secs.to_f
  if secs > 2
    data[lang] = secs
  else
    p lang
    other += secs
  end
end

g.add_color '#ff9966'
g.add_color '#889977'
g.add_color '#dd77aa'
g.add_color '#bbddaa'
g.add_color '#aa8888'
g.add_color '#77dd99'
g.add_color '#555555'
g.add_color '#eecccc'
data.sort_by { |k, v| v }.reverse_each do |lang, secs|
  g.data lang, secs
end

g.data 'other', other if other > 0
p other

FILE = 'test/scanners/tests_pie.png'
g.write FILE
`open #{FILE}`

__END__
~/ruby/coderay norandom=1 rake test:scanners
(in /Users/murphy/ruby/coderay)
Loaded suite CodeRay::Scanners
Started

    >> Testing C scanner <<

Loading examples in test/scanners/c/*.in.c...7 examples found.
          elvis    0.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
          empty    0.0K: incremental, -skipped- complete, identity, highlighting, finished in  0.00s.
          error    0.0K: incremental, -skipped- complete, identity, highlighting, finished in  0.00s.
         error2    0.0K: incremental, -skipped- complete, identity, highlighting, finished in  0.00s.
    open-string    0.0K: incremental, -skipped- complete, identity, highlighting, finished in  0.00s.
           ruby 2297.4K: incremental, shuffled, complete, identity, highlighting, finished in  5.62s ( 115 Ktok/s).
        strange    3.7K: incremental, shuffled, complete, identity, highlighting, finished in  0.01s ( 110 Ktok/s).
Finished in 15.59s.
.
    >> Testing C++ scanner <<

Loading examples in test/scanners/cpp/*.in.cpp...4 examples found.
          elvis    0.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
   eventmachine  180.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.24s ( 133 Ktok/s).
          pleac   57.2K: incremental, shuffled, complete, identity, highlighting, finished in  0.07s ( 137 Ktok/s).
       wedekind    0.1K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
Finished in 1.75s.
.
    >> Testing CSS scanner <<

Loading examples in test/scanners/css/*.in.css...5 examples found.
 ignos-draconis   28.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.07s ( 127 Ktok/s).
        redmine   22.6K: incremental, shuffled, complete, identity, highlighting, finished in  0.06s ( 125 Ktok/s).
             S5    7.0K: incremental, shuffled, complete, identity, highlighting, finished in  0.02s ( 131 Ktok/s).
       standard    0.2K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
            yui  380.1K: incremental, shuffled, complete, identity, highlighting, finished in  1.07s (  96 Ktok/s).
Finished in 7.88s.
.
    >> Testing CodeRay Token Dump scanner <<

Loading examples in test/scanners/debug/*.in.raydebug...2 examples found.
          class    1.6K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s ( 119 Ktok/s).
           kate    8.5K: incremental, shuffled, complete, identity, highlighting, finished in  0.01s ( 125 Ktok/s).
Finished in 1.72s.
.
    >> Testing Delphi scanner <<

Loading examples in test/scanners/delphi/*.in.pas...2 examples found.
          pluto  278.1K: incremental, shuffled, complete, identity, highlighting, finished in  0.81s (  93 Ktok/s).
         ytools   64.0K: incremental, shuffled, complete, identity, highlighting, finished in  0.36s (  64 Ktok/s).
Finished in 3.64s.
.
    >> Testing diff output scanner <<

Loading examples in test/scanners/diff/*.in.diff...2 examples found.
coderay200vs250   66.2K: incremental, shuffled, complete, identity, highlighting, finished in  0.05s ( 188 Ktok/s).
        example    0.8K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
Finished in 0.69s.
.
    >> Testing Groovy scanner <<

Loading examples in test/scanners/groovy/*.in.groovy...4 examples found.
          pleac  381.2K: incremental, shuffled, complete, identity, highlighting, finished in  0.87s (  88 Ktok/s).
     raistlin77   14.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.03s ( 124 Ktok/s).
        strange    0.0K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
        strings    1.1K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s ( 120 Ktok/s).
Finished in 4.60s.
.
    >> Testing HTML scanner <<

Loading examples in test/scanners/html/*.in.html...3 examples found.
      ampersand    0.0K: incremental, -skipped- complete, identity, highlighting, finished in  0.00s.
 coderay-output  123.0K: incremental, shuffled, complete, identity, highlighting, finished in  0.32s ( 137 Ktok/s).
        tolkien   12.3K: incremental, shuffled, complete, identity, highlighting, finished in  0.02s ( 144 Ktok/s).
Finished in 2.20s.
.
    >> Testing Java scanner <<

Loading examples in test/scanners/java/*.in.java...1 example found.
          jruby 1854.9K: incremental, shuffled, complete, identity, highlighting, finished in  3.62s ( 120 Ktok/s).
Finished in 7.98s.
.
    >> Testing JavaScript scanner <<

Loading examples in test/scanners/javascript/*.in.js...5 examples found.
      prototype  126.7K: incremental, shuffled, complete, identity, highlighting, finished in  0.35s ( 122 Ktok/s).
script.aculo.us  225.6K: incremental, shuffled, complete, identity, highlighting, finished in  0.59s ( 126 Ktok/s).
     sun-spider  916.0K: incremental, shuffled, complete, identity, highlighting, finished in  1.82s ( 110 Ktok/s).
     trace-test  151.1K: incremental, shuffled, complete, identity, highlighting, finished in  0.41s ( 133 Ktok/s).
            xml    0.1K: incremental, shuffled, ticket ?, identity, highlighting, finished in  0.00s.
            KNOWN ISSUE: JavaScript scanner is confused by nested XML literals.
                         No ticket yet. Visit http://odd-eyed-code.org/projects/coderay/issues/new.
Finished in 10.07s.
.
    >> Testing JSON scanner <<

Loading examples in test/scanners/json/*.in.json...4 examples found.
            big    9.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.02s ( 166 Ktok/s).
           big2    7.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.02s ( 173 Ktok/s).
        example    0.5K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
       json-lib    1.7K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s ( 163 Ktok/s).
Finished in 3.85s.
.
    >> Testing Nitro XHTML scanner <<

Loading examples in test/scanners/nitro/*.in.xhtml...1 example found.
           tags    2.6K: incremental, shuffled, complete, identity, highlighting, finished in  0.01s ( 109 Ktok/s).
Finished in 1.74s.
.
    >> Testing PHP scanner <<

Loading examples in test/scanners/php/*.in.php...7 examples found.
          class    1.5K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s ( 112 Ktok/s).
          elvis    0.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
html+php_faulty    0.0K: incremental, -skipped- complete, identity, highlighting, finished in  0.00s.
         labels    0.5K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
          pleac  145.8K: incremental, shuffled, complete, identity, highlighting, finished in  0.59s (  63 Ktok/s).
        strings    9.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.01s ( 119 Ktok/s).
           test   16.7K: incremental, shuffled, complete, identity, highlighting, finished in  0.03s ( 114 Ktok/s).
Finished in 5.18s.
.
    >> Testing Python scanner <<

Loading examples in test/scanners/python/*.in.py...6 examples found.
         import    1.1K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s ( 135 Ktok/s).
       literals    0.5K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
          pleac  297.2K: incremental, shuffled, complete, identity, highlighting, finished in  0.60s ( 133 Ktok/s).
       pygments  953.6K: incremental, shuffled, complete, identity, highlighting, finished in  2.55s ( 118 Ktok/s).
        python3    0.5K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
      unistring  394.8K: incremental, shuffled, complete, identity, highlighting, finished in  0.99s (  69 Ktok/s).
Finished in 11.30s.
.
    >> Testing HTML ERB Template scanner <<

Loading examples in test/scanners/rhtml/*.in.rhtml...1 example found.
            day    0.6K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
Finished in 0.91s.
.
    >> Testing Ruby scanner <<

Loading examples in test/scanners/ruby/*.in.rb...26 examples found.
              1   18.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.07s ( 112 Ktok/s).
      besetzung    1.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s ( 103 Ktok/s).
          class    1.6K: incremental, shuffled, complete, identity, highlighting, finished in  0.01s ( 106 Ktok/s).
        comment    0.1K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
         diffed    0.9K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
           evil   15.6K: incremental, shuffled, complete, identity, highlighting, finished in  0.06s (  99 Ktok/s).
        example  100.2K: incremental, shuffled, complete, identity, highlighting, finished in  0.21s ( 109 Ktok/s).
           jarh   11.1K: incremental, shuffled, complete, identity, highlighting, finished in  0.04s ( 110 Ktok/s).
 nested-heredoc    0.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
   open-heredoc    0.0K: incremental, -skipped- complete, identity, highlighting, finished in  0.00s.
    open-inline    0.0K: incremental, -skipped- complete, identity, highlighting, finished in  0.00s.
    open-string    0.0K: incremental, -skipped- complete, identity, highlighting, finished in  0.00s.
      operators    0.6K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
          pleac  156.6K: incremental, shuffled, complete, identity, highlighting, finished in  0.37s ( 110 Ktok/s).
         quotes    0.1K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
          rails 2634.1K: incremental, shuffled, complete, identity, highlighting, finished in  5.61s (  94 Ktok/s).
         regexp    0.5K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
         ruby19    0.1K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
     sidebarize    3.7K: incremental, shuffled, complete, identity, highlighting, finished in  0.02s (  35 Ktok/s).
         simple    0.0K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
        strange   17.5K: incremental, shuffled, complete, identity, highlighting, finished in  0.10s (  91 Ktok/s).
    test-fitter    0.6K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
        tk-calc    0.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
          undef    0.2K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
        unicode    0.5K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
           zero    0.0K: incremental, -skipped- complete, identity, highlighting, finished in  0.00s.
Finished in 33.82s.
.
    >> Testing Scheme scanner <<

Loading examples in test/scanners/scheme/*.in.scm...2 examples found.
          pleac  143.7K: incremental, shuffled, complete, identity, highlighting, finished in  0.27s ( 141 Ktok/s).
        strange    1.1K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s ( 129 Ktok/s).
Finished in 1.91s.
.
    >> Testing SQL scanner <<

Loading examples in test/scanners/sql/*.in.sql...4 examples found.
  create_tables    3.0K: incremental, shuffled, complete, identity, highlighting, finished in  0.01s ( 142 Ktok/s).
    maintenance    1.0K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
      reference    2.7K: incremental, shuffled, complete, identity, highlighting, finished in  0.01s ( 145 Ktok/s).
        selects    1.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s ( 140 Ktok/s).
Finished in 2.22s.
.
    >> Testing XML scanner <<

Loading examples in test/scanners/xml/*.in.xml...1 example found.
           kate    3.9K: incremental, shuffled, complete, identity, highlighting, finished in  0.01s ( 148 Ktok/s).
Finished in 0.92s.
.
    >> Testing YAML scanner <<

Loading examples in test/scanners/yaml/*.in.yml...8 examples found.
          basic   24.5K: incremental, shuffled, complete, identity, highlighting, finished in  0.02s ( 121 Ktok/s).
       database    0.6K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
            faq   16.2K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s ( 123 Ktok/s).
        gemspec    3.0K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s ( 115 Ktok/s).
 latex_entities   48.4K: incremental, shuffled, complete, identity, highlighting, finished in  0.08s ( 143 Ktok/s).
      multiline    0.7K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s.
      threshold   22.6K: incremental, shuffled, complete, identity, highlighting, finished in  0.02s ( 113 Ktok/s).
        website    3.7K: incremental, shuffled, complete, identity, highlighting, finished in  0.00s ( 109 Ktok/s).
Finished in 5.33s.
.
Finished in 123.310808 seconds.

20 tests, 0 assertions, 0 failures, 0 errors
