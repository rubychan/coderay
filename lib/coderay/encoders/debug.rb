module CodeRay
	module Encoders

		# = Debug Encoder
		class Debug < Encoder

			include Streamable
			register_for :debug

			FILE_EXTENSION = 'raydebug'

		protected
			def text_token text, kind
				@out <<
					if kind == :space
						text
					else
						text = text.gsub(/[)\\]/, '\\\\\0')
						"#{kind}(#{text})"
					end					
			end

			def block_token action, kind
				@out << super
			end

			def open_token kind
				"#{kind}<"
			end

			def close_token kind
				">"
			end

		end

	end
end
