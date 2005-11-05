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
			#  IDENT_KIND = WordList.new(:ident).
			#    add(RESERVED_WORDS, :reserved).
			#    add(PREDEFINED_TYPES, :pre_type).
			#    add(PREDEFINED_CONSTANTS, :pre_constant)
			#
			#  ...
			#
			#  def scan_tokens tokens, options
			#    ...
			#    
			#    elsif scan(/[A-Za-z_][A-Za-z_0-9]*/)
			#      # use it
			#      kind = IDENT_KIND[match]
			#      ...
			#  
			class WordList < Hash

				# Creates a new WordList with +default+ as default value.
				def initialize default = false, &block
					super default, &block
				end

				# Checks if a word is included.
				def include? word
					has_key? word
				end

				# Add words to the list and associate them with +kind+.
				def add words, kind = true
					words.each do |word|
						self[word] = kind
					end
					self
				end

			end
			

			class CaseIgnoringWordList < WordList

				# Creates a new WordList with +default+ as default value.
				#
				# Text case is ignored.
				def initialize default = false
					super() do |h, k|
						h[k] = h.fetch k.downcase, default
					end
				end

				# Checks if a word is included.
				def include? word
					has_key? word.downcase
				end

				# Add words to the list and associate them with +kind+.
				def add words, kind = true
					words.each do |word|
						self[word.downcase] = kind
					end
					self
				end

			end		

		end

	end
end

# vim:sw=2:ts=2:noet:tw=78
