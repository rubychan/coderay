module CodeRay
module Encoders
  
  map \
    :loc => :lines_of_code,
    :term => :terminal,
    :plain => :text,
    :remove_comments => :comment_filter,
    :stats => :statistic,
    :tex => :latex
  
  # No default because Tokens#nonsense would not raise NoMethodError.
  
end
end
