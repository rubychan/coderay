module CodeRay
	module Encoders

		class Null < Encoder

			include Streamable
			register_for :null

			protected

			def token(*)
				# do nothing
			end

		end

	end
end


