require 'rubygems'
require 'gruff'

g = Gruff::Line.new
g.title = 'Supported Languages in CodeRay'
g.hide_dots = true

data, labels = [0], {}
repo_creation = Date.parse `svn info -r1`[/Last Changed Date: ([-\d]+)/,1]
index = 1
$stdout.sync = true
for day in repo_creation..Date.today
  if day.mday == 1  # only check on 1st day of the month
    labels[index] = day.year.to_s if day.month == 1
    index += 1
    data << `svn ls lib/coderay/scanners -r{#{day}} | \\
      grep '^[[:alpha:]]\\w\\+.rb' | wc -l`.to_i
    print day, "\r"
  end
end
puts

g.data 'CodeRay', data
g.labels = labels

FILE = 'test/scanners/languages_over_time.png'
g.write FILE
`open #{FILE}`
