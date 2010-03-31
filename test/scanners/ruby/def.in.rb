# simple method definitions

def method param1, param2
  # code
end

def method(args, *rest, &block)
  # code
end

def
method(param1, param2)
  # code
end

def \
method(param1, param2)
  # code
end

def # comment
method(param1, param2)
  # code
end

def [];end
def def;end
def end?;end
def a(*) end
def !; end  # Ruby 1.9.1


# singleton methods

def Class.method
end

def self.method
end

def object.method
end

def object.Method
end

def $~.method
end

def nil.method
end
def true.method
end
def false.method
end
def __FILE__.method
end
def __LINE__.method
end
def __ENCODING__.method
end
def __ENCODING__.method
end

def @instance_variable.method
end

def @class_variable.method
end

def (Module::Class).method
end

def (complex.expression).method
end

def (complex.expression + another(complex(expression))).method
end


# crazy

def (class Foo
  def initialize(args)
    def yet_another_method; end
  end
end).method(args, *rest, &block)
end

# wrong
def foo.bar.quux
end
