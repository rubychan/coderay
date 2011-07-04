module CodeRay
module Encoders
  
  map \
    :loc             => :lines_of_code,
    :html            => :page,
    :plain           => :text,
    :plaintext       => :text,
    :remove_comments => :comment_filter,
    :stats           => :statistic,
    :term            => :terminal,
    :tty             => :terminal
  
  # No default because Tokens#nonsense should raise NoMethodError.
  
end
end
