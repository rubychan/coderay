# = WordList
# 
# Copyright (c) 2006 by murphy (Kornelius Kalnbach) <murphy cYcnus de>
#
# License:: LGPL / ask the author
# Version:: 1.0 (2006-Feb-3)
# 
# A WordList is a Hash with some additional features.
# It is intended to be used for keyword recognition.
#
# WordList is highly optimized to be used in Scanners,
# typically to decide whether a given ident is a keyword.
#
# For case insensitive words use CaseIgnoringWordList.
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

	# Create a WordList for the given +words+.
	#
	# This WordList responds to [] with +true+, if the word is
	# in +words+, and with +false+ otherwise.
	def self.for words
		new.add words
	end

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


# A CaseIgnoringWordList is like a WordList, only that
# keys are compared case-insensitively.
class CaseIgnoringWordList < WordList

	# Creates a new WordList with +default+ as default value.
	#
	# Text case is ignored.
	def initialize default = false, &block
		block ||= proc do |h, k|
			h[k] = h.fetch k.downcase, default
		end
		super default 
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
