module CodeRay
module Encoders
  
  load :token_filter
  
  class CommentFilter < TokenFilter

    register_for :comment_filter

    DEFAULT_OPTIONS = TokenFilter::DEFAULT_OPTIONS.merge \
      :exclude => [:comment]

end
end
