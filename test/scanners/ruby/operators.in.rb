class Feeling
  
  def ~
    p :drunk
  end
  
  def !
    p :alert
  end
  
  alias not !@
  alias tilde ~@
  
  def -@
    p :bad
  end
  
  def +@
    p :good
  end
  
end

feeling = Feeling.new

-feeling  # => :bad
+feeling  # => :good
!feeling  # => :alert
~feeling  # => :drunk

def =~ other
  bla
end

feeling.!  # => :alert
feeling.~  # => :drunk
feeling.!@  # => :alert
feeling.~@  # => :drunk
feeling.-@()  # => :bad
feeling.+@()  # => :good

# >> :bad
# >> :good
# >> :alert
# >> :drunk
# >> :alert
# >> :drunk
# >> :alert
# >> :drunk
# >> :bad
# >> :good
