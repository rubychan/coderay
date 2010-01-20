class TokenClass
  def self.const_missing name
    const_set name, Class.new(self)
  end
  def self.method_missing name, &block
    clas = const_missing name
    if block
      clas.instance_eval(&block)
    end
  end
end

class Comment < TokenClass
  Multiline
  class Shebang < self
    Foo
  end
end

p Comment::Blubb::Bla <= Comment::Blubb

ObjectSpace.each_object(Class) { |o| p o if o < TokenClass }