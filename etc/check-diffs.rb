DIFF_PART = /
^ ([\d,]+c[\d,]+) \n # change
( (?: < .* \n )+ )  # old
---\n
( (?: > .* \n )+ )  # new
/x

class String
  def undiff!
    gsub!(/^./, '')
  end
end

for diff in Dir['*.debug.diff']
  puts diff
  diff = File.read diff
  diff.scan(/#{DIFF_PART}|(.+)/o) do |change, old, new, error|
    raise error if error
    old.undiff!
    new.undiff!
    
    new.gsub!('inline_delimiter', 'delimiter')
    unless new == old
      raise "\n>>>\n#{new}\n<<<#{old}\n"
    end
  end
end