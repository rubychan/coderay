module CodeRay module Encoders
	
	require 'coderay/encoders/html'
	class Span < HTML

		FILE_EXTENSION = 'span.html'

		register_for :span

		DEFAULT_OPTIONS = HTML::DEFAULT_OPTIONS.merge({
			:css => :style,
			:wrap => :span,
			:line_numbers => nil,
		})
	end

end end
