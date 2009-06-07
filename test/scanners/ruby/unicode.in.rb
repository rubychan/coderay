ä = 42
print ä

def straße(frühstück)
  höhle(frühstück)
end

alias λ lambda
× = λ{ |x,y| x*y}
×[2,3]  # => 6

# Summe der ersten 10 Quadratzahlen
def ∑ enum
  enum.inject(0) { |sum, x| sum + yield(x) }
end

∑(1..10) { |x| x**2 }  # => 385

# mehr Mathematische Zeichen
def ∞; 1.0 / 0.0; end
def π; Math::PI; end

-∞ .. 2*π  # => -Infinity..6.28318530717959

# Azumanga Daioh Insider
class << Osaka = Object.new
  def ぁ!
    sleep ∞
  end
end