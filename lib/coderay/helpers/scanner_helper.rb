module CodeRay
	module Scanners

		class Scanner

			# A WordList is a Hash with some additional features.
			# It is intended to be used for keyword recognition.
			#
			# WordList is highly optimized to be used in Scanners,
			# typically to decide whether a given ident is a keyword.
			#
			# Example:
			# 
			#  # define word arrays
			#  RESERVED_WORDS = %w[
			#    asm break case continue default do else
			#    ...		
			#  ]
			#  
			#  PREDEFINED_TYPES = %w[
			#    int long short char void
			#    ...
			#  ]
			#  
			#  PREDEFINED_CONSTANTS = %w[
			#    EOF NULL ...
			#  ]
			#  
			#  # make a WordList
			#  IDENT_KIND = Scanner::WordList.new(:ident).
			#    add(RESERVED_WORDS, :reserved).
			#    add(PREDEFINED_TYPES, :pre_type).
			#    add(PREDEFINED_CONSTANTS, :pre_constant)
			#
			#  ...
			#
			#  def scan_tokens tokens, options
			#    ...
			#    
			#    elsif match = scan(/ [A-Za-z_][A-Za-z_0-9]* /x)
			#      # use it
			#      kind = IDENT_KIND[match]
			#      ...
			#  
			class WordList < Hash

				# Creates a new WordList with +default+ as default value.
				# case_mode controls how keys are compared;
				# :case_match is faster.
				def initialize default = false, case_mode = :case_match
					@case_ignore =
						case case_mode
						when :case_match then false
						when :case_ignore then true
						else raise ArgumentError,
							":case_ignore or :case_match expected, but #{case_mode} given"
						end

					if @case_ignore
						super() do |h, k|
							h[k] = h.fetch k.downcase, default
						end
					else
						super default
					end
				end

				# Checks if a word is included.
				def include? word
					self[word] if @case_ignore
					has_key? word
				end

				# Add words to the list and associate them with
				# +kind+.
				def add words, kind = true
					words.each do |word|
						self[mind_case(word)] = kind
					end
					self
				end

				alias words keys

				# Returns whether key comparing is done case insensitive.
				def case_ignore?
					@case_mode
				end

			private
				# helper method for key 
				def mind_case word
					if @case_ignore
						word.downcase
					else
						word.dup
					end
				end

			end		

		end

	end
end

# vim:sw=2:ts=2:noet:tw=78
