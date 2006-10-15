module CodeRay
	module Scanners

class Ruby < Scanner

	RESERVED_WORDS = [
		'and', 'def', 'end', 'in', 'or', 'unless', 'begin',
		'defined?', 'ensure', 'module', 'redo', 'super', 'until',
		'BEGIN', 'break', 'do', 'next', 'rescue', 'then',
		'when', 'END', 'case', 'else', 'for', 'retry',
		'while', 'alias', 'class', 'elsif', 'if', 'not', 'return',
		'undef', 'yield',
	]

	DEF_KEYWORDS = ['def']
	MODULE_KEYWORDS = ['class', 'module']
	DEF_NEW_STATE = WordList.new(:initial).
		add(DEF_KEYWORDS, :def_expected).
		add(MODULE_KEYWORDS, :module_expected)

	WORDS_ALLOWING_REGEXP = [
		'and', 'or', 'not', 'while', 'until', 'unless', 'if', 'elsif', 'when'
	]
	REGEXP_ALLOWED = WordList.new(false).
		add(WORDS_ALLOWING_REGEXP, :set)

	PREDEFINED_CONSTANTS = [
		'nil', 'true', 'false', 'self',
		'DATA', 'ARGV', 'ARGF', '__FILE__', '__LINE__',
	]

	IDENT_KIND = WordList.new(:ident).
		add(RESERVED_WORDS, :reserved).
		add(PREDEFINED_CONSTANTS, :pre_constant)

	METHOD_NAME = / #{IDENT} [?!]? /xo
	METHOD_NAME_EX = /
	 #{METHOD_NAME}  # common methods: split, foo=, empty?, gsub!
	 | \*\*?         # multiplication and power
	 | [-+~]@?       # plus, minus
	 | [\/%&|^`]     # division, modulo or format strings, &and, |or, ^xor, `system`
	 | \[\]=?        # array getter and setter
	 | <=?>? | >=?   # comparison, rocket operator
	 | << | >>       # append or shift left, shift right
	 | ===?          # simple equality and case equality
	/ox
	GLOBAL_VARIABLE = / \$ (?: #{IDENT} | \d+ | [~&+`'=\/,;_.<>!@0$?*":F\\] | -[a-zA-Z_0-9] ) /ox

	DOUBLEQ = / "  [^"\#\\]*  (?: (?: \#\{.*?\} | \#(?:$")?  | \\. ) [^"\#\\]*  )* "?  /ox
	SINGLEQ = / '  [^'\\]*    (?:                              \\.   [^'\\]*    )* '?  /ox
	STRING  = / #{SINGLEQ} | #{DOUBLEQ} /ox
	SHELL   = / `  [^`\#\\]*  (?: (?: \#\{.*?\} | \#(?:$`)?  | \\. ) [^`\#\\]*  )* `?  /ox
	REGEXP  = / \/ [^\/\#\\]* (?: (?: \#\{.*?\} | \#(?:$\/)? | \\. ) [^\/\#\\]* )* \/? /ox

	DECIMAL = /\d+(?:_\d+)*/  # doesn't recognize 09 as octal error
	OCTAL = /0_?[0-7]+(?:_[0-7]+)*/
	HEXADECIMAL = /0x[0-9A-Fa-f]+(?:_[0-9A-Fa-f]+)*/
	BINARY = /0b[01]+(?:_[01]+)*/

	EXPONENT = / [eE] [+-]? #{DECIMAL} /ox
	FLOAT = / #{DECIMAL} (?: #{EXPONENT} | \. #{DECIMAL} #{EXPONENT}? ) /
	INTEGER = /#{OCTAL}|#{HEXADECIMAL}|#{BINARY}|#{DECIMAL}/

	def reset
		super
		@regexp_allowed = false
	end

	def next_token
		return if @scanner.eos?

		kind = :error
		if @scanner.scan(/\s+/)  # in every state
			kind = :space
			@regexp_allowed = :set if @regexp_allowed or @scanner.matched.index(?\n)  # delayed flag setting

		elsif @state == :def_expected
			if @scanner.scan(/ (?: (?:#{IDENT}(?:\.|::))* | (?:@@?|$)? #{IDENT}(?:\.|::) ) #{METHOD_NAME_EX} /ox)
				kind = :method
				@state = :initial
			else
				@scanner.getch
			end
			@state = :initial

		elsif @state == :module_expected
			if @scanner.scan(/<</)
				kind = :operator
			else
				if @scanner.scan(/ (?: #{IDENT} (?:\.|::))* #{IDENT} /ox)
					kind = :method
				else
					@scanner.getch
				end
				@state = :initial
			end

		elsif # state == :initial
			# IDENTIFIERS, KEYWORDS
			if @scanner.scan(GLOBAL_VARIABLE)
				kind = :global_variable
			elsif @scanner.scan(/ @@ #{IDENT} /ox)
				kind = :class_variable
			elsif @scanner.scan(/ @ #{IDENT} /ox)
				kind = :instance_variable
			elsif @scanner.scan(/ __END__\n ( (?!\#CODE\#) .* )? | \#[^\n]* | =begin(?=\s).*? \n=end(?=\s|\z)(?:[^\n]*)? /mx)
				kind = :comment
			elsif @scanner.scan(METHOD_NAME)
				if @last_token_dot
					kind = :ident
				else
					matched = @scanner.matched
					kind = IDENT_KIND[matched]
					if kind == :ident and matched =~ /^[A-Z]/
						kind = :constant
					elsif kind == :reserved
						@state = DEF_NEW_STATE[matched]
						@regexp_allowed = REGEXP_ALLOWED[matched]
					end
				end

			elsif @scanner.scan(STRING)
				kind = :string
			elsif @scanner.scan(SHELL)
				kind = :shell
			elsif @scanner.scan(/<<
				(?:
					([a-zA-Z_0-9]+)
						(?: .*? ^\1$ | .* )
				|
					-([a-zA-Z_0-9]+)
						(?: .*? ^\s*\2$ | .* )
				|
					(["\'`]) (.+?) \3
						(?: .*? ^\4$ | .* )
				|
					- (["\'`]) (.+?) \5
						(?: .*? ^\s*\6$ | .* )
				)
			/mxo)
				kind = :string
			elsif @scanner.scan(/\//) and @regexp_allowed
				@scanner.unscan
				@scanner.scan(REGEXP)
				kind = :regexp
/%(?:[Qqxrw](?:\([^)#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^)#\\\\]*)*\)?|\[[^\]#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^\]#\\\\]*)*\]?|\{[^}#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^}#\\\\]*)*\}?|<[^>#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^>#\\\\]*)*>?|([^a-zA-Z\\\\])(?:(?!\1)[^#\\\\])*(?:(?:#\{.*?\}|#|\\\\.)(?:(?!\1)[^#\\\\])*)*\1?)|\([^)#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^)#\\\\]*)*\)?|\[[^\]#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^\]#\\\\]*)*\]?|\{[^}#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^}#\\\\]*)*\}?|<[^>#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^>#\\\\]*)*>?|([^a-zA-Z\s\\\\])(?:(?!\2)[^#\\\\])*(?:(?:#\{.*?\}|#|\\\\.)(?:(?!\2)[^#\\\\])*)*\2?|\\\\[^#\\\\]*(?:(?:#\{.*?\}|#)[^#\\\\]*)*\\\\?)/
			elsif @scanner.scan(/:(?:#{GLOBAL_VARIABLE}|#{METHOD_NAME_EX}|#{STRING})/ox)
				kind = :symbol
			elsif @scanner.scan(/
				\? (?:
					[^\s\\]
				|
					\\ (?:M-\\C-|C-\\M-|M-\\c|c\\M-|c|C-|M-))? (?: \\ (?: . | [0-7]{3} | x[0-9A-Fa-f][0-9A-Fa-f] )
				)
			/mox)
				kind = :integer

			elsif @scanner.scan(/ [-+*\/%=<>;,|&!()\[\]{}~?] | \.\.?\.? | ::? /x)
				kind = :operator
				@regexp_allowed = :set if @scanner.matched[-1,1] =~ /[~=!<>|&^,\(\[+\-\/\*%]\z/
			elsif @scanner.scan(FLOAT)
				kind = :float
			elsif @scanner.scan(INTEGER)
				kind = :integer
			else
				@scanner.getch
			end
		end

		token = Token.new @scanner.matched, kind

		if kind == :regexp
			token.text << @scanner.scan(/[eimnosux]*/)
		end

		@regexp_allowed = (@regexp_allowed == :set)  # delayed flag setting

		token
	end
end

register Ruby, 'ruby', 'rb'

	end
end
class Set
  include Enumerable

  # Creates a new set containing the given objects.
  def self.[](*ary)
    new(ary)
  end

  # Creates a new set containing the elements of the given enumerable
  # object.
  #
  # If a block is given, the elements of enum are preprocessed by the
  # given block.
  def initialize(enum = nil, &block) # :yields: o
    @hash ||= Hash.new

    enum.nil? and return

    if block
      enum.each { |o| add(block[o]) }
    else
      merge(enum)
    end
  end

  # Copy internal hash.
  def initialize_copy(orig)
    @hash = orig.instance_eval{@hash}.dup
  end

  # Returns the number of elements.
  def size
    @hash.size
  end
  alias length size

  # Returns true if the set contains no elements.
  def empty?
    @hash.empty?
  end

  # Removes all elements and returns self.
  def clear
    @hash.clear
    self
  end

  # Replaces the contents of the set with the contents of the given
  # enumerable object and returns self.
  def replace(enum)
    if enum.class == self.class
      @hash.replace(enum.instance_eval { @hash })
    else
      enum.is_a?(Enumerable) or raise ArgumentError, "value must be enumerable"
      clear
      enum.each { |o| add(o) }
    end

    self
  end

  # Converts the set to an array.  The order of elements is uncertain.
  def to_a
    @hash.keys
  end

  def flatten_merge(set, seen = Set.new)
    set.each { |e|
      if e.is_a?(Set)
	if seen.include?(e_id = e.object_id)
	  raise ArgumentError, "tried to flatten recursive Set"
	end

	seen.add(e_id)
	flatten_merge(e, seen)
	seen.delete(e_id)
      else
	add(e)
      end
    }

    self
  end
  protected :flatten_merge

  # Returns a new set that is a copy of the set, flattening each
  # containing set recursively.
  def flatten
    self.class.new.flatten_merge(self)
  end

  # Equivalent to Set#flatten, but replaces the receiver with the
  # result in place.  Returns nil if no modifications were made.
  def flatten!
    if detect { |e| e.is_a?(Set) }
      replace(flatten())
    else
      nil
    end
  end

  # Returns true if the set contains the given object.
  def include?(o)
    @hash.include?(o)
  end
  alias member? include?

  # Returns true if the set is a superset of the given set.
  def superset?(set)
    set.is_a?(Set) or raise ArgumentError, "value must be a set"
    return false if size < set.size
    set.all? { |o| include?(o) }
  end

  # Returns true if the set is a proper superset of the given set.
  def proper_superset?(set)
    set.is_a?(Set) or raise ArgumentError, "value must be a set"
    return false if size <= set.size
    set.all? { |o| include?(o) }
  end

  # Returns true if the set is a subset of the given set.
  def subset?(set)
    set.is_a?(Set) or raise ArgumentError, "value must be a set"
    return false if set.size < size
    all? { |o| set.include?(o) }
  end

  # Returns true if the set is a proper subset of the given set.
  def proper_subset?(set)
    set.is_a?(Set) or raise ArgumentError, "value must be a set"
    return false if set.size <= size
    all? { |o| set.include?(o) }
  end

  # Calls the given block once for each element in the set, passing
  # the element as parameter.
  def each
    @hash.each_key { |o| yield(o) }
    self
  end

  # Adds the given object to the set and returns self.  Use +merge+ to
  # add several elements at once.
  def add(o)
    @hash[o] = true
    self
  end
  alias << add

  # Adds the given object to the set and returns self.  If the
  # object is already in the set, returns nil.
  def add?(o)
    if include?(o)
      nil
    else
      add(o)
    end
  end

  # Deletes the given object from the set and returns self.  Use +subtract+ to
  # delete several items at once.
  def delete(o)
    @hash.delete(o)
    self
  end

  # Deletes the given object from the set and returns self.  If the
  # object is not in the set, returns nil.
  def delete?(o)
    if include?(o)
      delete(o)
    else
      nil
    end
  end

  # Deletes every element of the set for which block evaluates to
  # true, and returns self.
  def delete_if
    @hash.delete_if { |o,| yield(o) }
    self
  end

  # Do collect() destructively.
  def collect!
    set = self.class.new
    each { |o| set << yield(o) }
    replace(set)
  end
  alias map! collect!

  # Equivalent to Set#delete_if, but returns nil if no changes were
  # made.
  def reject!
    n = size
    delete_if { |o| yield(o) }
    size == n ? nil : self
  end

  # Merges the elements of the given enumerable object to the set and
  # returns self.
  def merge(enum)
    if enum.is_a?(Set)
      @hash.update(enum.instance_eval { @hash })
    else
      enum.is_a?(Enumerable) or raise ArgumentError, "value must be enumerable"
      enum.each { |o| add(o) }
    end

    self
  end

  # Deletes every element that appears in the given enumerable object
  # and returns self.
  def subtract(enum)
    enum.is_a?(Enumerable) or raise ArgumentError, "value must be enumerable"
    enum.each { |o| delete(o) }
    self
  end

  # Returns a new set built by merging the set and the elements of the
  # given enumerable object.
  def |(enum)
    enum.is_a?(Enumerable) or raise ArgumentError, "value must be enumerable"
    dup.merge(enum)
  end
  alias + |		##
  alias union |		##

  # Returns a new set built by duplicating the set, removing every
  # element that appears in the given enumerable object.
  def -(enum)
    enum.is_a?(Enumerable) or raise ArgumentError, "value must be enumerable"
    dup.subtract(enum)
  end
  alias difference -	##

  # Returns a new array containing elements common to the set and the
  # given enumerable object.
  def &(enum)
    enum.is_a?(Enumerable) or raise ArgumentError, "value must be enumerable"
    n = self.class.new
    enum.each { |o| n.add(o) if include?(o) }
    n
  end
  alias intersection &	##

  # Returns a new array containing elements exclusive between the set
  # and the given enumerable object.  (set ^ enum) is equivalent to
  # ((set | enum) - (set & enum)).
  def ^(enum)
    enum.is_a?(Enumerable) or raise ArgumentError, "value must be enumerable"
    n = dup
    enum.each { |o| if n.include?(o) then n.delete(o) else n.add(o) end }
    n
  end

  # Returns true if two sets are equal.  The equality of each couple
  # of elements is defined according to Object#eql?.
  def ==(set)
    equal?(set) and return true

    set.is_a?(Set) && size == set.size or return false

    hash = @hash.dup
    set.all? { |o| hash.include?(o) }
  end

  def hash	# :nodoc:
    @hash.hash
  end

  def eql?(o)	# :nodoc:
    return false unless o.is_a?(Set)
    @hash.eql?(o.instance_eval{@hash})
  end

  # Classifies the set by the return value of the given block and
  # returns a hash of {value => set of elements} pairs.  The block is
  # called once for each element of the set, passing the element as
  # parameter.
  #
  # e.g.:
  #
  #   require 'set'
  #   files = Set.new(Dir.glob("*.rb"))
  #   hash = files.classify { |f| File.mtime(f).year }
  #   p hash    # => {2000=>#<Set: {"a.rb", "b.rb"}>,
  #             #     2001=>#<Set: {"c.rb", "d.rb", "e.rb"}>,
  #             #     2002=>#<Set: {"f.rb"}>}
  def classify # :yields: o
    h = {}

    each { |i|
      x = yield(i)
      (h[x] ||= self.class.new).add(i)
    }

    h
  end

  # Divides the set into a set of subsets according to the commonality
  # defined by the given block.
  #
  # If the arity of the block is 2, elements o1 and o2 are in common
  # if block.call(o1, o2) is true.  Otherwise, elements o1 and o2 are
  # in common if block.call(o1) == block.call(o2).
  #
  # e.g.:
  #
  #   require 'set'
  #   numbers = Set[1, 3, 4, 6, 9, 10, 11]
  #   set = numbers.divide { |i,j| (i - j).abs == 1 }
  #   p set     # => #<Set: {#<Set: {1}>,
  #             #            #<Set: {11, 9, 10}>,
  #             #            #<Set: {3, 4}>,
  #             #            #<Set: {6}>}>
  def divide(&func)
    if func.arity == 2
      require 'tsort'

      class << dig = {}		# :nodoc:
	include TSort

	alias tsort_each_node each_key
	def tsort_each_child(node, &block)
	  fetch(node).each(&block)
	end
      end

      each { |u|
	dig[u] = a = []
	each{ |v| func.call(u, v) and a << v }
      }

      set = Set.new()
      dig.each_strongly_connected_component { |css|
	set.add(self.class.new(css))
      }
      set
    else
      Set.new(classify(&func).values)
    end
  end

  InspectKey = :__inspect_key__         # :nodoc:

  # Returns a string containing a human-readable representation of the
  # set. ("#<Set: {element1, element2, ...}>")
  def inspect
    ids = (Thread.current[InspectKey] ||= [])

    if ids.include?(object_id)
      return sprintf('#<%s: {...}>', self.class.name)
    end

    begin
      ids << object_id
      return sprintf('#<%s: {%s}>', self.class, to_a.inspect[1..-2])
    ensure
      ids.pop
    end
  end

  def pretty_print(pp)	# :nodoc:
    pp.text sprintf('#<%s: {', self.class.name)
    pp.nest(1) {
      pp.seplist(self) { |o|
	pp.pp o
      }
    }
    pp.text "}>"
  end

  def pretty_print_cycle(pp)	# :nodoc:
    pp.text sprintf('#<%s: {%s}>', self.class.name, empty? ? '' : '...')
  end
end

# SortedSet implements a set which elements are sorted in order.  See Set.
class SortedSet < Set
  @@setup = false

  class << self
    def [](*ary)	# :nodoc:
      new(ary)
    end

    def setup	# :nodoc:
      @@setup and return

      begin
	require 'rbtree'

	module_eval %{
	  def initialize(*args, &block)
	    @hash = RBTree.new
	    super
	  end
	}
      rescue LoadError
	module_eval %{
	  def initialize(*args, &block)
	    @keys = nil
	    super
	  end

	  def clear
	    @keys = nil
	    super
	  end

	  def replace(enum)
	    @keys = nil
	    super
	  end

	  def add(o)
	    @keys = nil
	    @hash[o] = true
	    self
	  end
	  alias << add

	  def delete(o)
	    @keys = nil
	    @hash.delete(o)
	    self
	  end

	  def delete_if
	    n = @hash.size
	    @hash.delete_if { |o,| yield(o) }
	    @keys = nil if @hash.size != n
	    self
	  end

	  def merge(enum)
	    @keys = nil
	    super
	  end

	  def each
	    to_a.each { |o| yield(o) }
	  end

	  def to_a
	    (@keys = @hash.keys).sort! unless @keys
	    @keys
	  end
	}
      end

      @@setup = true
    end
  end

  def initialize(*args, &block)	# :nodoc:
    SortedSet.setup
    initialize(*args, &block)
  end
end

module Enumerable
  # Makes a set from the enumerable object with given arguments.
  def to_set(klass = Set, *args, &block)
    klass.new(self, *args, &block)
  end
end

# =begin
# == RestricedSet class
# RestricedSet implements a set with restrictions defined by a given
# block.
#
# === Super class
#     Set
#
# === Class Methods
# --- RestricedSet::new(enum = nil) { |o| ... }
# --- RestricedSet::new(enum = nil) { |rset, o| ... }
#     Creates a new restricted set containing the elements of the given
#     enumerable object.  Restrictions are defined by the given block.
#
#     If the block's arity is 2, it is called with the RestrictedSet
#     itself and an object to see if the object is allowed to be put in
#     the set.
#
#     Otherwise, the block is called with an object to see if the object
#     is allowed to be put in the set.
#
# === Instance Methods
# --- restriction_proc
#     Returns the restriction procedure of the set.
#
# =end
#
# class RestricedSet < Set
#   def initialize(*args, &block)
#     @proc = block or raise ArgumentError, "missing a block"
#
#     if @proc.arity == 2
#       instance_eval %{
# 	def add(o)
# 	  @hash[o] = true if @proc.call(self, o)
# 	  self
# 	end
# 	alias << add
#
# 	def add?(o)
# 	  if include?(o) || !@proc.call(self, o)
# 	    nil
# 	  else
# 	    @hash[o] = true
# 	    self
# 	  end
# 	end
#
# 	def replace(enum)
# 	  enum.is_a?(Enumerable) or raise ArgumentError, "value must be enumerable"
# 	  clear
# 	  enum.each { |o| add(o) }
#
# 	  self
# 	end
#
# 	def merge(enum)
# 	  enum.is_a?(Enumerable) or raise ArgumentError, "value must be enumerable"
# 	  enum.each { |o| add(o) }
#
# 	  self
# 	end
#       }
#     else
#       instance_eval %{
# 	def add(o)
#         if @proc.call(o)
# 	    @hash[o] = true
#         end
# 	  self
# 	end
# 	alias << add
#
# 	def add?(o)
# 	  if include?(o) || !@proc.call(o)
# 	    nil
# 	  else
# 	    @hash[o] = true
# 	    self
# 	  end
# 	end
#       }
#     end
#
#     super(*args)
#   end
#
#   def restriction_proc
#     @proc
#   end
# end

if $0 == __FILE__
  eval DATA.read, nil, $0, __LINE__+4
end

# = rweb - CGI Support Library
#
# Author:: Johannes Barre (mailto:rweb@igels.net)
# Copyright:: Copyright (c) 2003, 04 by Johannes Barre
# License:: GNU Lesser General Public License (COPYING, http://www.gnu.org/copyleft/lesser.html)
# Version:: 0.1.0
# CVS-ID:: $Id: rweb.rb 6 2004-06-16 15:56:26Z igel $
#
# == What is Rweb?
# Rweb is a replacement for the cgi class included in the ruby distribution.
#
# == How to use
#
# === Basics
#
# This class is made to be as easy as possible to use. An example:
#
# 	require "rweb"
#
# 	web = Rweb.new
# 	web.out do
# 		web.puts "Hello world!"
# 	end
#
# The visitor will get a simple "Hello World!" in his browser. Please notice,
# that won't set html-tags for you, so you should better do something like this:
#
# 	require "rweb"
#
# 	web = Rweb.new
# 	web.out do
# 		web.puts "<html><body>Hello world!</body></html>"
# 	end
#
# === Set headers
# Of course, it's also possible to tell the browser, that the content of this
# page is plain text instead of html code:
#
# 	require "rweb"
#
# 	web = Rweb.new
# 	web.out do
# 		web.header("content-type: text/plain")
# 		web.puts "Hello plain world!"
# 	end
#
# Please remember, headers can't be set after the page content has been send.
# You have to set all nessessary headers before the first puts oder print. It's
# possible to cache the content until everything is complete. Doing it this
# way, you can set headers everywhere.
#
# If you set a header twice, the second header will replace the first one. The
# header name is not casesensitive, it will allways converted in to the
# capitalised form suggested by the w3c (http://w3.org)
#
# === Set cookies
# Setting cookies is quite easy:
# 	include 'rweb'
#
# 	web = Rweb.new
# 	Cookie.new("Visits", web.cookies['visits'].to_i +1)
# 	web.out do
# 		web.puts "Welcome back! You visited this page #{web.cookies['visits'].to_i +1} times"
# 	end
#
# See the class Cookie for more details.
#
# === Get form and cookie values
# There are four ways to submit data from the browser to the server and your
# ruby script: via GET, POST, cookies and file upload. Rweb doesn't support
# file upload by now.
#
# 	include 'rweb'
#
# 	web = Rweb.new
# 	web.out do
# 		web.print "action: #{web.get['action']} "
# 		web.puts "The value of the cookie 'visits' is #{web.cookies['visits']}"
# 		web.puts "The post parameter 'test['x']' is #{web.post['test']['x']}"
# 	end

RWEB_VERSION = "0.1.0"
RWEB = "rweb/#{RWEB_VERSION}"

#require 'rwebcookie' -> edit by bunny :-)

class Rweb
    # All parameter submitted via the GET method are available in attribute
		# get. This is Hash, where every parameter is available as a key-value
		# pair.
		#
		# If your input tag has a name like this one, it's value will be available
		# as web.get["fieldname"]
		#  <input name="fieldname">
		# You can submit values as a Hash
		#  <input name="text['index']">
		#  <input name="text['index2']">
		# will be available as
		#  web.get["text"]["index"]
		#  web.get["text"]["index2"]
		# Integers are also possible
		#  <input name="int[2]">
		#  <input name="int[3]['hi']>
		# will be available as
		#  web.get["int"][2]
		#  web.get["int"][3]["hi"]
		# If you specify no index, the lowest unused index will be used:
		#  <input name="int[]"><!-- First Field -->
		#  <input name="int[]"><!-- Second one -->
		# will be available as
		#  web.get["int"][0] # First Field
		#  web.get["int"][1] # Second one
		# Please notice, this doesn'd work like you might expect:
		#  <input name="text[index]">
		# It will not be available as web.get["text"]["index"] but
		#  web.get["text[index]"]
    attr_reader :get

    # All parameters submitted via POST are available in the attribute post. It
		# works like the get attribute.
		#  <input name="text[0]">
		# will be available as
		#  web.post["text"][0]
		attr_reader :post

    # All cookies submitted by the browser are available in cookies. This is a
		# Hash, where every cookie is a key-value pair.
		attr_reader :cookies

    # The name of the browser identification is submitted as USER_AGENT and
		# available in this attribute.
		attr_reader :user_agent

    # The IP address of the client.
		attr_reader :remote_addr

    # Creates a new Rweb object. This should only done once. You can set various
    # options via the settings hash.
    #
    # "cache" => true: Everything you script send to the client will be cached
    # until the end of the out block or until flush is called. This way, you
    # can modify headers and cookies even after printing something to the client.
    #
    # "safe" => level: Changes the $SAFE attribute. By default, $SAFE will be set
    # to 1. If $SAFE is already higher than this value, it won't be changed.
    #
    # "silend" => true: Normaly, Rweb adds automaticly a header like this
    # "X-Powered-By: Rweb/x.x.x (Ruby/y.y.y)". With the silend option you can
    # suppress this.
    def initialize (settings = {})
        # {{{
        @header = {}
        @cookies = {}
        @get = {}
        @post = {}

        # Internal attributes
        @status = nil
        @reasonPhrase = nil
        @setcookies = []
        @output_started = false;
        @output_allowed = false;

        @mod_ruby = false
        @env = ENV.to_hash

        if defined?(MOD_RUBY)
            @output_method = "mod_ruby"
            @mod_ruby = true
        elsif @env['SERVER_SOFTWARE'] =~ /^Microsoft-IIS/i
            @output_method = "nph"
        else
            @output_method = "ph"
        end

        unless settings.is_a?(Hash)
            raise TypeError, "settings must be a Hash"
        end
        @settings = settings

        unless @settings.has_key?("safe")
            @settings["safe"] = 1
        end

        if $SAFE < @settings["safe"]
            $SAFE = @settings["safe"]
        end

        unless @settings.has_key?("cache")
            @settings["cache"] = false
        end

        # mod_ruby sets no QUERY_STRING variable, if no GET-Parameters are given
        unless @env.has_key?("QUERY_STRING")
            @env["QUERY_STRING"] = ""
        end

        # Now we split the QUERY_STRING by the seperators & and ; or, if
        # specified, settings['get seperator']
        unless @settings.has_key?("get seperator")
            get_args = @env['QUERY_STRING'].split(/[&;]/)
        else
            get_args = @env['QUERY_STRING'].split(@settings['get seperator'])
        end

        get_args.each do | arg |
            arg_key, arg_val = arg.split(/=/, 2)
            arg_key = Rweb::unescape(arg_key)
            arg_val = Rweb::unescape(arg_val)

            # Parse names like name[0], name['text'] or name[]
            pattern = /^(.+)\[("[^\]]*"|'[^\]]*'|[0-9]*)\]$/
            keys = []
            while match = pattern.match(arg_key)
                arg_key = match[1]
                keys = [match[2]] + keys
            end
            keys = [arg_key] + keys

            akt = @get
            last = nil
            lastkey = nil
            keys.each do |key|
                if key == ""
                    # No key specified (like in "test[]"), so we use the
                    # lowerst unused Integer as key
                    key = 0
                    while akt.has_key?(key)
                        key += 1
                    end
                elsif /^[0-9]*$/ =~ key
                    # If the index is numerical convert it to an Integer
                    key = key.to_i
                elsif key[0].chr == "'" || key[0].chr == '"'
                    key = key[1, key.length() -2]
                end
                if !akt.has_key?(key) || !akt[key].class == Hash
                    # create an empty Hash if there isn't already one
                    akt[key] = {}
                end
                last = akt
                lastkey = key
                akt = akt[key]
            end
            last[lastkey] = arg_val
        end

        if @env['REQUEST_METHOD'] == "POST"
            if @env.has_key?("CONTENT_TYPE") && @env['CONTENT_TYPE'] == "application/x-www-form-urlencoded" && @env.has_key?('CONTENT_LENGTH')
                unless @settings.has_key?("post seperator")
                    post_args = $stdin.read(@env['CONTENT_LENGTH'].to_i).split(/[&;]/)
                else
                    post_args = $stdin.read(@env['CONTENT_LENGTH'].to_i).split(@settings['post seperator'])
                end
                post_args.each do | arg |
                    arg_key, arg_val = arg.split(/=/, 2)
                    arg_key = Rweb::unescape(arg_key)
                    arg_val = Rweb::unescape(arg_val)

                    # Parse names like name[0], name['text'] or name[]
                    pattern = /^(.+)\[("[^\]]*"|'[^\]]*'|[0-9]*)\]$/
                    keys = []
                    while match = pattern.match(arg_key)
                        arg_key = match[1]
                        keys = [match[2]] + keys
                    end
                    keys = [arg_key] + keys

                    akt = @post
                    last = nil
                    lastkey = nil
                    keys.each do |key|
                        if key == ""
                            # No key specified (like in "test[]"), so we use
                            # the lowerst unused Integer as key
                            key = 0
                            while akt.has_key?(key)
                                key += 1
                            end
                        elsif /^[0-9]*$/ =~ key
                            # If the index is numerical convert it to an Integer
                            key = key.to_i
                        elsif key[0].chr == "'" || key[0].chr == '"'
                            key = key[1, key.length() -2]
                        end
                        if !akt.has_key?(key) || !akt[key].class == Hash
                            # create an empty Hash if there isn't already one
                            akt[key] = {}
                        end
                        last = akt
                        lastkey = key
                        akt = akt[key]
                    end
                    last[lastkey] = arg_val
                end
            else
                # Maybe we should print a warning here?
                $stderr.print("Unidentified form data recived and discarded.")
            end
        end

        if @env.has_key?("HTTP_COOKIE")
            cookie = @env['HTTP_COOKIE'].split(/; ?/)
            cookie.each do | c |
                cookie_key, cookie_val = c.split(/=/, 2)

                @cookies [Rweb::unescape(cookie_key)] = Rweb::unescape(cookie_val)
            end
        end

        if defined?(@env['HTTP_USER_AGENT'])
            @user_agent = @env['HTTP_USER_AGENT']
        else
            @user_agent = nil;
        end

        if defined?(@env['REMOTE_ADDR'])
            @remote_addr = @env['REMOTE_ADDR']
        else
            @remote_addr = nil
        end
        # }}}
    end

    # Prints a String to the client. If caching is enabled, the String will
    # buffered until the end of the out block ends.
    def print(str = "")
        # {{{
        unless @output_allowed
            raise "You just can write to output inside of a Rweb::out-block"
        end

        if @settings["cache"]
            @buffer += [str.to_s]
        else
            unless @output_started
                sendHeaders
            end
            $stdout.print(str)
        end
        nil
        # }}}
    end

    # Prints a String to the client and adds a line break at the end. Please
		# remember, that a line break is not visible in HTML, use the <br> HTML-Tag
		# for this. If caching is enabled, the String will buffered until the end
		# of the out block ends.
    def puts(str = "")
        # {{{
        self.print(str + "\n")
        # }}}
    end

		# Alias to print.
    def write(str = "")
        # {{{
        self.print(str)
        # }}}
    end

    # If caching is enabled, all cached data are send to the cliend and the
		# cache emptied.
    def flush
        # {{{
        unless @output_allowed
            raise "You can't use flush outside of a Rweb::out-block"
        end
        buffer = @buffer.join

        unless @output_started
            sendHeaders
        end
        $stdout.print(buffer)

        @buffer = []
        # }}}
    end

    # Sends one or more header to the client. All headers are cached just
		# before body data are send to the client. If the same header are set
		# twice, only the last value is send.
		#
		# Example:
		#  web.header("Last-Modified: Mon, 16 Feb 2004 20:15:41 GMT")
		#  web.header("Location: http://www.ruby-lang.org")
		#
		# You can specify more than one header at the time by doing something like
		# this:
		#  web.header("Content-Type: text/plain\nContent-Length: 383")
		# or
		#  web.header(["Content-Type: text/plain", "Content-Length: 383"])
    def header(str)
        # {{{
        if @output_started
            raise "HTTP-Headers are already send. You can't change them after output has started!"
        end
        unless @output_allowed
            raise "You just can set headers inside of a Rweb::out-block"
        end
        if str.is_a?Array
            str.each do | value |
                self.header(value)
            end

        elsif str.split(/\n/).length > 1
            str.split(/\n/).each do | value |
                self.header(value)
            end

        elsif str.is_a? String
            str.gsub!(/\r/, "")

            if (str =~ /^HTTP\/1\.[01] [0-9]{3} ?.*$/) == 0
                pattern = /^HTTP\/1.[01] ([0-9]{3}) ?(.*)$/

                result = pattern.match(str)
                self.setstatus(result[0], result[1])
            elsif (str =~ /^status: [0-9]{3} ?.*$/i) == 0
                pattern = /^status: ([0-9]{3}) ?(.*)$/i

                result = pattern.match(str)
                self.setstatus(result[0], result[1])
            else
                a = str.split(/: ?/, 2)

                @header[a[0].downcase] = a[1]
            end
        end
        # }}}
    end

    # Changes the status of this page. There are several codes like "200 OK",
		# "302 Found", "404 Not Found" or "500 Internal Server Error". A list of
		# all codes is available at
		# http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10
		#
		# You can just send the code number, the reason phrase will be added
		# automaticly with the recommendations from the w3c if not specified. If
		# you set the status twice or more, only the last status will be send.
		# Examples:
		#  web.status("401 Unauthorized")
		#  web.status("410 Sad but true, this lonely page is gone :(")
		#  web.status(206)
		#  web.status("400")
		#
		# The default status is "200 OK". If a "Location" header is set, the
		# default status is "302 Found".
    def status(str)
        # {{{
        if @output_started
            raise "HTTP-Headers are already send. You can't change them after output has started!"
        end
        unless @output_allowed
            raise "You just can set headers inside of a Rweb::out-block"
        end
        if str.is_a?Integer
            @status = str
        elsif str.is_a?String
            p1 = /^([0-9]{3}) ?(.*)$/
            p2 = /^HTTP\/1\.[01] ([0-9]{3}) ?(.*)$/
            p3 = /^status: ([0-9]{3}) ?(.*)$/i

            if (a = p1.match(str)) == nil
                if (a = p2.match(str)) == nil
                    if (a = p3.match(str)) == nil
                        raise ArgumentError, "Invalid argument", caller
                    end
                end
            end
            @status = a[1].to_i
            if a[2] != ""
                @reasonPhrase = a[2]
            else
                @reasonPhrase = getReasonPhrase(@status)
            end
        else
            raise ArgumentError, "Argument of setstatus must be integer or string", caller
        end
        # }}}
    end

    # Handles the output of your content and rescues all exceptions. Send all
		# data in the block to this method. For example:
		#  web.out do
		#      web.header("Content-Type: text/plain")
		#      web.puts("Hello, plain world!")
		#  end
    def out
        # {{{
        @output_allowed = true
        @buffer = []; # We use an array as buffer, because it's more performant :)

        begin
            yield
        rescue Exception => exception
            $stderr.puts "Ruby exception rescued (#{exception.class}): #{exception.message}"
            $stderr.puts exception.backtrace.join("\n")

            unless @output_started
                self.setstatus(500)
                @header = {}
            end

            unless (@settings.has_key?("hide errors") and @settings["hide errors"] == true)
                unless @output_started
                    self.header("Content-Type: text/html")
                    self.puts "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Strict//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">"
                    self.puts "<html>"
                    self.puts "<head>"
                    self.puts "<title>500 Internal Server Error</title>"
                    self.puts "</head>"
                    self.puts "<body>"
                end
                if @header.has_key?("content-type") and (@header["content-type"] =~ /^text\/html/i) == 0
                    self.puts "<h1>Internal Server Error</h1>"
                    self.puts "<p>The server encountered an exception and was unable to complete your request.</p>"
                    self.puts "<p>The exception has provided the following information:</p>"
                    self.puts "<pre style=\"background: #FFCCCC; border: black solid 2px; margin-left: 2cm; margin-right: 2cm; padding: 2mm;\"><b>#{exception.class}</b>: #{exception.message} <b>on</b>"
                    self.puts
                    self.puts "#{exception.backtrace.join("\n")}</pre>"
                    self.puts "</body>"
                    self.puts "</html>"
                else
                    self.puts "The server encountered an exception and was unable to complete your request"
                    self.puts "The exception has provided the following information:"
                    self.puts "#{exception.class}: #{exception.message}"
                    self.puts
                    self.puts exception.backtrace.join("\n")
                end
            end
        end

        if @settings["cache"]
            buffer = @buffer.join

            unless @output_started
                unless @header.has_key?("content-length")
                    self.header("content-length: #{buffer.length}")
                end

                sendHeaders
            end
            $stdout.print(buffer)
        elsif !@output_started
            sendHeaders
        end
        @output_allowed = false;
        # }}}
    end

    # Decodes URL encoded data, %20 for example stands for a space.
    def Rweb.unescape(str)
        # {{{
        if defined? str and str.is_a? String
            str.gsub!(/\+/, " ")
            str.gsub(/%.{2}/) do | s |
                s[1,2].hex.chr
            end
        end
        # }}}
    end

    protected
    def sendHeaders
        # {{{

        Cookie.disallow # no more cookies can be set or modified
        if !(@settings.has_key?("silent") and @settings["silent"] == true) and !@header.has_key?("x-powered-by")
            if @mod_ruby
                header("x-powered-by: #{RWEB} (Ruby/#{RUBY_VERSION}, #{MOD_RUBY})");
            else
                header("x-powered-by: #{RWEB} (Ruby/#{RUBY_VERSION})");
            end
        end

        if @output_method == "ph"
            if ((@status == nil or @status == 200) and !@header.has_key?("content-type") and !@header.has_key?("location"))
                header("content-type: text/html")
            end

            if @status != nil
                $stdout.print "Status: #{@status} #{@reasonPhrase}\r\n"
            end

            @header.each do |key, value|
                key = key *1 # "unfreeze" key :)
                key[0] = key[0,1].upcase![0]

                key = key.gsub(/-[a-z]/) do |char|
                    "-" + char[1,1].upcase
                end

                $stdout.print "#{key}: #{value}\r\n"
            end
            cookies = Cookie.getHttpHeader # Get all cookies as an HTTP Header
            if cookies
                $stdout.print cookies
            end

            $stdout.print "\r\n"

        elsif @output_method == "nph"
        elsif @output_method == "mod_ruby"
            r = Apache.request

            if ((@status == nil or @status == 200) and !@header.has_key?("content-type") and !@header.has_key?("location"))
                header("text/html")
            end

            if @status != nil
                r.status_line = "#{@status} #{@reasonPhrase}"
            end

            r.send_http_header
            @header.each do |key, value|
                key = key *1 # "unfreeze" key :)

                key[0] = key[0,1].upcase![0]
                key = key.gsub(/-[a-z]/) do |char|
                    "-" + char[1,1].upcase
                end
                puts "#{key}: #{value.class}"
                #r.headers_out[key] = value
            end
        end
        @output_started = true
        # }}}
    end

    def getReasonPhrase (status)
        # {{{
        if status == 100
            "Continue"
        elsif status == 101
            "Switching Protocols"
        elsif status == 200
            "OK"
        elsif status == 201
            "Created"
        elsif status == 202
            "Accepted"
        elsif status == 203
            "Non-Authoritative Information"
        elsif status == 204
            "No Content"
        elsif status == 205
            "Reset Content"
        elsif status == 206
            "Partial Content"
        elsif status == 300
            "Multiple Choices"
        elsif status == 301
            "Moved Permanently"
        elsif status == 302
            "Found"
        elsif status == 303
            "See Other"
        elsif status == 304
            "Not Modified"
        elsif status == 305
            "Use Proxy"
        elsif status == 307
            "Temporary Redirect"
        elsif status == 400
            "Bad Request"
        elsif status == 401
            "Unauthorized"
        elsif status == 402
            "Payment Required"
        elsif status == 403
            "Forbidden"
        elsif status == 404
            "Not Found"
        elsif status == 405
            "Method Not Allowed"
        elsif status == 406
            "Not Acceptable"
        elsif status == 407
            "Proxy Authentication Required"
        elsif status == 408
            "Request Time-out"
        elsif status == 409
            "Conflict"
        elsif status == 410
            "Gone"
        elsif status == 411
            "Length Required"
        elsif status == 412
            "Precondition Failed"
        elsif status == 413
            "Request Entity Too Large"
        elsif status == 414
            "Request-URI Too Large"
        elsif status == 415
            "Unsupported Media Type"
        elsif status == 416
            "Requested range not satisfiable"
        elsif status == 417
            "Expectation Failed"
        elsif status == 500
            "Internal Server Error"
        elsif status == 501
            "Not Implemented"
        elsif status == 502
            "Bad Gateway"
        elsif status == 503
            "Service Unavailable"
        elsif status == 504
            "Gateway Time-out"
        elsif status == 505
            "HTTP Version not supported"
        else
            raise "Unknown Statuscode. See http://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html#sec6.1 for more information."
        end
        # }}}
    end
end

class Cookie
	attr_reader :name, :value, :maxage, :path, :domain, :secure, :comment

	# Sets a cookie. Please see below for details of the attributes.
	def initialize (name, value = nil, maxage = nil, path = nil, domain = nil, secure = false)
		# {{{
		# HTTP headers (Cookies are a HTTP header) can only set, while no content
		# is send. So an exception will be raised, when @@allowed is set to false
		# and a new cookie has set.
		unless defined?(@@allowed)
			@@allowed = true
		end
		unless @@allowed
			raise "You can't set cookies after the HTTP headers are send."
		end

		unless defined?(@@list)
			@@list = []
		end
		@@list += [self]

		unless defined?(@@type)
			@@type = "netscape"
		end

		unless name.class == String
			raise TypeError, "The name of a cookie must be a string", caller
		end
		if value.class.superclass == Integer || value.class == Float
			value = value.to_s
		elsif value.class != String && value != nil
			raise TypeError, "The value of a cookie must be a string, integer, float or nil", caller
		end
		if maxage.class == Time
			maxage = maxage - Time.now
		elsif !maxage.class.superclass == Integer  || !maxage == nil
			raise TypeError, "The maxage date of a cookie must be an Integer or Time object or nil.", caller
		end
		unless path.class == String  || path == nil
			raise TypeError, "The path of a cookie must be nil or a string", caller
		end
		unless domain.class == String  || domain == nil
			raise TypeError, "The value of a cookie must be nil or a string", caller
		end
		unless secure == true  || secure == false
			raise TypeError, "The secure field of a cookie must be true or false", caller
		end

		@name, @value, @maxage, @path, @domain, @secure = name, value, maxage, path, domain, secure
		@comment = nil
		# }}}
	end

	# Modifies the value of this cookie. The information you want to store. If the
	# value is nil, the cookie will be deleted by the client.
	#
	# This attribute can be a String, Integer or Float object or nil.
	def value=(value)
		# {{{
		if value.class.superclass == Integer || value.class == Float
			value = value.to_s
		elsif value.class != String && value != nil
			raise TypeError, "The value of a cookie must be a string, integer, float or nil", caller
		end
		@value = value
		# }}}
	end

	# Modifies the maxage of this cookie. This attribute defines the lifetime of
	# the cookie, in seconds. A value of 0 means the cookie should be discarded
	# imediatly. If it set to nil, the cookie will be deleted when the browser
	# will be closed.
	#
	# Attention: This is different from other implementations like PHP, where you
	# gives the seconds since 1/1/1970 0:00:00 GMT.
	#
	# This attribute must be an Integer or Time object or nil.
	def maxage=(maxage)
		# {{{
		if maxage.class == Time
			maxage = maxage - Time.now
		elsif maxage.class.superclass == Integer  || !maxage == nil
			raise TypeError, "The maxage of a cookie must be an Interger or Time object or nil.", caller
		end
		@maxage = maxage
		# }}}
	end

	# Modifies the path value of this cookie. The client will send this cookie
	# only, if the requested document is this directory or a subdirectory of it.
	#
	# The value of the attribute must be a String object or nil.
	def path=(path)
		# {{{
		unless path.class == String  || path == nil
			raise TypeError, "The path of a cookie must be nil or a string", caller
		end
		@path = path
		# }}}
	end

	# Modifies the domain value of this cookie. The client will send this cookie
	# only if it's connected with this domain (or a subdomain, if the first
	# character is a dot like in ".ruby-lang.org")
	#
	# The value of this attribute must be a String or nil.
	def domain=(domain)
		# {{{
		unless domain.class == String  || domain == nil
			raise TypeError, "The domain of a cookie must be a String or nil.", caller
		end
		@domain = domain
		# }}}
	end

	# Modifies the secure flag of this cookie. If it's true, the client will only
	# send this cookie if it is secured connected with us.
	#
	# The value od this attribute has to be true or false.
	def secure=(secure)
		# {{{
		unless secure == true  || secure == false
			raise TypeError, "The secure field of a cookie must be true or false", caller
		end
		@secure = secure
		# }}}
	end

	# Modifies the comment value of this cookie. The comment won't be send, if
	# type is "netscape".
	def comment=(comment)
		# {{{
		unless comment.class == String || comment == nil
			raise TypeError, "The comment of a cookie must be a string or nil", caller
		end
		@comment = comment
		# }}}
	end

	# Changes the type of all cookies.
	# Allowed values are RFC2109 and netscape (default).
	def Cookie.type=(type)
		# {{{
		unless @@allowed
			raise "The cookies are allready send, so you can't change the type anymore."
		end
		unless type.downcase == "rfc2109" && type.downcase == "netscape"
			raise "The type of the cookies must be \"RFC2109\" or \"netscape\"."
		end
		@@type = type;
		# }}}
	end

	# After sending this message, no cookies can be set or modified. Use it, when
	# HTTP-Headers are send. Rweb does this for you.
	def Cookie.disallow
		# {{{
		@@allowed = false
		true
		# }}}
	end

	# Returns a HTTP header (type String) with all cookies. Rweb does this for
	# you.
	def Cookie.getHttpHeader
		# {{{
		if defined?(@@list)
			if @@type == "netscape"
				str = ""
				@@list.each do |cookie|
					if cookie.value == nil
						cookie.maxage = 0
						cookie.value = ""
					end
					# TODO: Name and value should be escaped!
					str += "Set-Cookie: #{cookie.name}=#{cookie.value}"
					unless cookie.maxage == nil
						expire = Time.now + cookie.maxage
						expire.gmtime
						str += "; Expire=#{expire.strftime("%a, %d-%b-%Y %H:%M:%S %Z")}"
					end
					unless cookie.domain == nil
						str += "; Domain=#{cookie.domain}"
					end
					unless cookie.path == nil
						str += "; Path=#{cookie.path}"
					end
					if cookie.secure
						str += "; Secure"
					end
					str += "\r\n"
				end
				return str
			else # type == "RFC2109"
				str = "Set-Cookie: "
				comma = false;

				@@list.each do |cookie|
					if cookie.value == nil
						cookie.maxage = 0
						cookie.value = ""
					end
					if comma
						str += ","
					end
					comma = true

					str += "#{cookie.name}=\"#{cookie.value}\""
					unless cookie.maxage == nil
						str += "; Max-Age=\"#{cookie.maxage}\""
					end
					unless cookie.domain == nil
						str += "; Domain=\"#{cookie.domain}\""
					end
					unless cookie.path == nil
						str += "; Path=\"#{cookie.path}\""
					end
					if cookie.secure
						str += "; Secure"
					end
					unless cookie.comment == nil
						str += "; Comment=\"#{cookie.comment}\""
					end
					str += "; Version=\"1\""
				end
				str
			end
		else
			false
		end
		# }}}
	end
end

require 'strscan'

module BBCode
	DEBUG = true

	use 'encoder', 'tags', 'tagstack', 'smileys'

=begin
	The Parser class takes care of the encoding.
	It scans the given BBCode (as plain text), finds tags
	and smilies and also makes links of urls in text.

	Normal text is send directly to the encoder.

	If a tag was found, an instance of a Tag subclass is created
	to handle the case.

	The @tagstack manages tag nesting and ensures valid HTML.
=end

	class Parser
		class Attribute
			# flatten and use only one empty_arg
			def self.create attr
				attr = flatten attr
				return @@empty_attr if attr.empty?
				new attr
			end

			private_class_method :new

			# remove leading and trailing whitespace; concat lines
			def self.flatten attr
				attr.strip.gsub(/\n/, ' ')
				# -> ^ and $ can only match at begin and end now
			end

			ATTRIBUTE_SCAN = /
				(?!$)  # don't match at end
				\s*
				( # $1 = key
					[^=\s\]"\\]*
					(?:
						(?: \\. | "[^"\\]*(?:\\.[^"\\]*)*"? )
						[^=\s\]"\\]*
					)*
				)
				(?:
					=
					( # $2 = value
						[^\s\]"\\]*
						(?:
							(?: \\. | "[^"\\]*(?:\\.[^"\\]*)*"? )
							[^\s\]"\\]*
						)*
					)?
				)?
				\s*
			/x

			def self.parse source
				source = source.dup
				# empty_tag: the tag looks like [... /]
				# slice!: this deletes the \s*/] at the end
				# \s+ because [url=http://rubybb.org/forum/] is NOT an empty tag.
				# In RubyBBCode, you can use [url=http://rubybb.org/forum/ /], and this has to be
				# interpreted correctly.
				empty_tag = source.sub!(/^:/, '=') or source.slice!(/\/$/)
				debug 'PARSE: ' + source.inspect + ' => ' + empty_tag.inspect
				#-> we have now an attr that's EITHER empty OR begins and ends with non-whitespace.

				attr = Hash.new
				attr[:flags] = []
				source.scan(ATTRIBUTE_SCAN) { |key, value|
					if not value
						attr[:flags] << unescape(key)
					else
						next if value.empty? and key.empty?
						attr[unescape(key)] = unescape(value)
					end
				}
				debug attr.inspect

				return empty_tag, attr
			end

			def self.unescape_char esc
				esc[1]
			end

			def self.unquote qt
				qt[1..-1].chomp('"').gsub(/\\./) { |esc| unescape_char esc }
			end

			def self.unescape str
				str.gsub(/ (\\.) | (" [^"\\]* (?:\\.[^"\\]*)* "?) /x) {
					if $1
						unescape_char $1
					else
						unquote $2
					end
				}
			end

			include Enumerable
			def each &block
				@args.each(&block)
			end

			attr_reader :source, :args, :value

			def initialize source
				@source = source
				debug 'Attribute#new(%p)' % source
				@empty_tag, @attr = Attribute.parse source
				@value = @attr[''].to_s
			end

			def empty?
				self == @@empty_attr
			end

			def empty_tag?
				@empty_tag
			end

			def [] *keys
				res = @attr[*keys]
			end

			def flags
				attr[:flags]
			end

			def to_s
				@attr
			end

			def inspect
				'ATTR[' + @attr.inspect + (@empty_tag ? ' | empty tag' : '') + ']'
			end
		end
		class Attribute
			@@empty_attr = new ''
		end
	end

	class Parser
		def Parser.flatten str
			# replace mac & dos newlines with unix style
			str.gsub(/\r\n?/, "\n")
		end

		def initialize input = ''
			# input manager
			@scanner = StringScanner.new ''
			# output manager
			@encoder = Encoder.new
			@output = ''
			# tag manager
			@tagstack = TagStack.new(@encoder)

			@do_magic = true
			# set the input
			feed input
		end

		# if you want, you can feed a parser instance after creating,
		# or even feed it repeatedly.
		def feed food
			@scanner.string = Parser.flatten food
		end

		# parse through the string using parse_token
		def parse
			parse_token until @scanner.eos?
			@tagstack.close_all
			@output = parse_magic @encoder.output
		end

		def output
			@output
		end

	# ok, internals start here
	private
		# the default output functions. everything should use them or the tags.
		def add_text text = @scanner.matched
			@encoder.add_text text
		end

		# use this carefully
		def add_html html
			@encoder.add_html html
		end

		# highlights the text as error
		def add_garbage garbage
			add_html '<span class="error">' if DEBUG
			add_text garbage
			add_html '</span>' if DEBUG
		end

		# unknown and incorrectly nested tags are ignored and
		# sent as plaintext (garbage in - garbage out).
		# in debug mode, garbage is marked with lime background.
		def garbage_out start
			@scanner.pos = start
			garbage = @scanner.scan(/./m)
			debug 'GARBAGE: ' + garbage
			add_garbage garbage
		end

		# simple text; everything but [, \[ allowed
		SIMPLE_TEXT_SCAN_ = /
			[^\[\\]*    # normal*
			(?:         # (
			\\.?        #   special
			[^\[\\]*    #   normal*
			)*          # )*
		/mx
		SIMPLE_TEXT_SCAN = /[^\[]+/

=begin

	WHAT IS A TAG?
	==============

	Tags in BBCode can be much more than just a simple [b].
	I use many terms here to differ the parts of each tag.

	Basic scheme:
	    [         code        ]
	TAG START   TAG INFO   TAG END

	Most tags need a second tag to close the range it opened.
	This is done with CLOSING TAGS:
		[/code]
	or by using empty tags that have no content and close themselfes:
		[url=winamp.com /]
	You surely know this from HTML.
	These slashes define the TAG KIND = normal|closing|empty and
	cannot be	used together.

	Everything between [ and ] and expluding the slashes is called the
	TAG INFO.	This info may contain:
	- TAG ID
	- TAG NAME including the tag id
	- attributes

	The TAG ID is the first char of the info:

	TAG       | ID
	----------+----
	[quote]   | q
	[&plusmn] | &
	["[b]"]   | "
	[/url]    | u
	[---]     | -

	As you can see, the tag id shows the TAG TYPE, it can be a
	normal tag,	a formatting tag or an entity.
	Therefor, the parser first scans the id to decide how to go
	on with parsing.
=end
		# tag
		# TODO more complex expression allowing
		#   [quote="[ladico]"] and [quote=\[ladico\]] to be correct tags
		TAG_BEGIN_SCAN = /
			\[             # tag start
			( \/ )?        # $1 = closing tag?
			( [^\]] )      # $2 = tag id
		/x
		TAG_END_SCAN = /
			[^\]]*         # rest that was not handled
			\]?            # tag end
		/x
		CLOSE_TAG_SCAN = /
			( [^\]]* )     # $1 = the rest of the tag info
			( \/ )?        # $2 = empty tag?
			\]?            # tag end
		/x
		UNCLOSED_TAG_SCAN = / \[ /x

		CLASSIC_TAG_SCAN = / [a-z]* /ix

		SEPARATOR_TAG_SCAN = / \** /x

		FORMAT_TAG_SCAN = / -- -* /x

		QUOTED_SCAN = /
			(            # $1 = quoted text
				[^"\\]*    # normal*
				(?:        # (
					\\.      # 	special
					[^"\\]*  # 	normal*
				)*         # )*
			)
			"?           # end quote "
		/mx

		ENTITY_SCAN = /
			( [^;\]]+ )  # $1 = entity code
			;?           # optional ending semicolon
		/ix

		SMILEY_SCAN = Smileys::SMILEY_PATTERN

		# this is the main parser loop that separates
		#   text - everything until "["
		# from
		#   tags - starting with "[", ending with "]"
		def parse_token
			if @scanner.scan(SIMPLE_TEXT_SCAN)
				add_text
			else
				handle_tag
			end
		end

		def handle_tag
			tag_start = @scanner.pos

			unless @scanner.scan TAG_BEGIN_SCAN
				garbage_out tag_start
				return
			end

			closing, id = @scanner[1], @scanner[2]
			#debug 'handle_tag(%p)' % @scanner.matched

			handled =
				case id

					when /[a-z]/i
						if @scanner.scan(CLASSIC_TAG_SCAN)
							if handle_classic_tag(id + @scanner.matched, closing)
								already_closed = true
							end
						end

					when '*'
						if @scanner.scan(SEPARATOR_TAG_SCAN)
							handle_asterisk tag_start, id + @scanner.matched
							true
						end

					when '-'
						if @scanner.scan(FORMAT_TAG_SCAN)
							#format = id + @scanner.matched
							@encoder.add_html "\n<hr>\n"
							true
						end

					when '"'
						if @scanner.scan(QUOTED_SCAN)
							@encoder.add_text unescape(@scanner[1])
							true
						end

					when '&'
						if @scanner.scan(ENTITY_SCAN)
							@encoder.add_entity @scanner[1]
							true
						end

					when Smileys::SMILEY_START_CHARSET
						@scanner.pos = @scanner.pos - 1  # (ungetch)
						if @scanner.scan(SMILEY_SCAN)
							@encoder.add_html Smileys.smiley_to_image(@scanner.matched)
							true
						end

				end # case

			return garbage_out(tag_start) unless handled

			@scanner.scan(TAG_END_SCAN) unless already_closed
		end

		ATTRIBUTES_SCAN = /
			(
				[^\]"\\]*
				(?:
					(?:
						\\.
					|
						"
						[^"\\]*
						(?:
							\\.
							[^"\\]*
						)*
						"?
					)
					[^\]"\\]*
				)*
			)
			\]?
		/x

		def handle_classic_tag name, closing
			debug 'TAG: ' + (closing ? '/' : '') + name
			# flatten
			name.downcase!
			tag_class = TAG_LIST[name]
			return unless tag_class

			#debug((opening ? 'OPEN ' : 'CLOSE ') + tag_class.name)

			# create an attribute object to handle it
			@scanner.scan(ATTRIBUTES_SCAN)
			#debug name + ':' + @scanner[1]
			attr = Attribute.create @scanner[1]
			#debug 'ATTRIBUTES %p ' % attr #unless attr.empty?

			#debug 'closing: %p; name=%s, attr=%p' % [closing, name, attr]

			# OPEN
			if not closing and tag = @tagstack.try_open_class(tag_class, attr)
				#debug 'opening'
				tag.do_open @scanner
				# this should be done by the tag itself.
				if attr.empty_tag?
					tag.handle_empty
					@tagstack.close_tag
				elsif tag.special_content?
					handle_special_content(tag)
					@tagstack.close_tag
					#        # ignore asterisks directly after the opening; these are phpBBCode
					#        elsif tag.respond_to? :asterisk
					#          debug 'SKIP ASTERISKS: ' if @scanner.skip(ASTERISK_TAGS_SCAN)
				end

			# CLOSE
			elsif @tagstack.try_close_class(tag_class)
				#debug 'closing'
				# GARBAGE
			else
				return
			end

			true
		end

		def handle_asterisk tag_start, stars
			#debug 'ASTERISK: ' + stars.to_s
			# rule for asterisk tags: they belong to the last tag
			# that handles them. tags opened after this tag are closed.
			# if no open tag uses them, all are closed.
			tag = @tagstack.close_all_until { |tag| tag.respond_to? :asterisk }
			unless tag and tag.asterisk stars, @scanner
				garbage_out tag_start
			end
		end

		def handle_special_content tag
			scanned = @scanner.scan_until(tag.closing_tag)
			if scanned
				scanned.slice!(-(@scanner.matched.size)..-1)
			else
				scanned = @scanner.scan(/.*/m).to_s
			end
			#debug 'SPECIAL CONTENT: ' + scanned
			tag.handle_content(scanned)
		end

		def unescape text
			# input: correctly formatted quoted string (without the quotes)
			text.gsub(/\\(?:(["\\])|.)/) { $1 or $& }
		end


		# MAGIC FEAUTURES

		URL_PATTERN = /(?:(?:www|ftp)\.|(?>\w{3,}):\/\/)\S+/
		EMAIL_PATTERN = /(?>[\w\-_.]+)@[\w\-\.]+\.\w+/

		HAS_MAGIC = /[&@#{Smileys::SMILEY_START_CHARS}]|(?i:www|ftp)/

		MAGIC_PATTERN = Regexp.new('(\W|^)(%s)' %
			[Smileys::MAGIC_SMILEY_PATTERN, URL_PATTERN, EMAIL_PATTERN].map { |pattern|
				pattern.to_s
			}.join('|') )

		IS_SMILEY_PATTERN = Regexp.new('^%s' % Smileys::SMILEY_START_CHARSET.to_s )
		IS_URL_PATTERN = /^(?:(?i:www|ftp)\.|(?>\w+):\/\/)/
		URL_STARTS_WITH_PROTOCOL = /^\w+:\/\//
		IS_EMAIL_PATTERN = /^[\w\-_.]+@/

		def to_magic text
			#      debug MAGIC_PATTERN.to_s
			text.gsub!(MAGIC_PATTERN) {
				magic = $2
				$1 + case magic
					when IS_SMILEY_PATTERN
						Smileys.smiley_to_img magic
					when IS_URL_PATTERN
						last = magic.slice_punctation!  # no punctation in my URL
						href = magic
						href.insert(0, 'http://') unless magic =~ URL_STARTS_WITH_PROTOCOL
						'<a href="' + href + '">' + magic + '</a>' + last
					when IS_EMAIL_PATTERN
						last = magic.slice_punctation!
						'<a href="mailto:' + magic + '">' + magic + '</a>' + last
				else
					raise '{{{' + magic + '}}}'
				end
			}
			text
		end

		# handles smileys and urls
		def parse_magic html
			return html unless @do_magic
			scanner = StringScanner.new html
			out = ''
			while scanner.rest?
				if scanner.scan(/ < (?: a\s .*? <\/a> | pre\W .*? <\/pre> | [^>]* > ) /mx)
					out << scanner.matched
				elsif scanner.scan(/ [^<]+ /x)
					out << to_magic(scanner.matched)

				# this should never happen
				elsif scanner.scan(/./m)
					raise 'ERROR: else case reached'
				end
			end
			out
		end
	end  # Parser
end

class String
	def slice_punctation!
		slice!(/[.:,!\?]+$/).to_s  # return '' instead of nil
	end
end

#
# = Grammar
#
# An implementation of common algorithms on grammars.
#
# This is used by Shinobu, a visualization tool for educating compiler-building.
#
# Thanks to Andreas Kunert for his wonderful LR(k) Pamphlet (German, see http://www.informatik.hu-berlin.de/~kunert/papers/lr-analyse), and Aho/Sethi/Ullman for their Dragon Book.
#
# Homepage::  http://shinobu.cYcnus.de (not existing yet)
# Author::    murphy (Kornelius Kalnbach)
# Copyright:: (cc) 2005 cYcnus
# License::   GPL
# Version:: 0.2.0 (2005-03-27)

require 'set_hash'
require 'ctype'
require 'tools'
require 'rules'
require 'trace'

require 'first'
require 'follow'

# = Grammar
#
# == Syntax
#
# === Rules
#
# Each line is a rule.
# The syntax is
#
# 	left - right
#
# where +left+ and +right+ can be uppercase and lowercase letters,
# and <code>-</code> can be any combination of <, >, - or whitespace.
#
# === Symbols
#
# Uppercase letters stand for meta symbols, lowercase for terminals.
#
# You can make epsilon-derivations by leaving <code><right></code> empty.
#
# === Example
# 	S - Ac
# 	A - Sc
# 	A - b
# 	A -
class Grammar

	attr_reader :tracer
	# Creates a new Grammar.
	# If $trace is true, the algorithms explain (textual) what they do to $stdout.
	def initialize data, tracer = Tracer.new
		@tracer = tracer
		@rules = Rules.new
		@terminals, @meta_symbols = SortedSet.new, Array.new
		@start_symbol = nil
		add_rules data
	end

	attr_reader :meta_symbols, :terminals, :rules, :start_symbol

	alias_method :sigma, :terminals
	alias_method :alphabet, :terminals
	alias_method :variables, :meta_symbols
	alias_method :nonterminals, :meta_symbols

	# A string representation of the grammar for debugging.
	def inspect productions_too = false
		'Grammar(meta symbols: %s; alphabet: %s; productions: [%s]; start symbol: %s)' %
			[
				meta_symbols.join(', '),
				terminals.join(', '),
				if productions_too
					@rules.inspect
				else
					@rules.size
				end,
				start_symbol
			]
	end

	# Add rules to the grammar. +rules+ should be a String or respond to +scan+ in a similar way.
	#
	# Syntax: see Grammar.
	def add_rules grammar
		@rules = Rules.parse grammar do |rule|
			@start_symbol ||= rule.left
			@meta_symbols << rule.left
			@terminals.merge rule.right.split('').select { |s| terminal? s }
		end
		@meta_symbols.uniq!
		update
	end

	# Returns a hash acting as FIRST operator, so that
	# <code>first["ABC"]</code> is FIRST(ABC).
	# See http://en.wikipedia.org/wiki/LL_parser "Constructing an LL(1) parsing table" for details.
	def first
		first_operator
	end

	# Returns a hash acting as FOLLOW operator, so that
	# <code>first["A"]</code> is FOLLOW(A).
	# See http://en.wikipedia.org/wiki/LL_parser "Constructing an LL(1) parsing table" for details.
	def follow
		follow_operator
	end

	LLError = Class.new(Exception)
	LLErrorType1 = Class.new(LLError)
	LLErrorType2 = Class.new(LLError)

	# Tests if the grammar is LL(1).
	def ll1?
		begin
			for meta in @meta_symbols
				first_sets = @rules[meta].map { |alpha| first[alpha] }
				first_sets.inject(Set[]) do |already_used, another_first_set|
					unless already_used.disjoint? another_first_set
						raise LLErrorType1
					end
					already_used.merge another_first_set
				end

				if first[meta].include? EPSILON and not first[meta].disjoint? follow[meta]
					raise LLErrorType2
				end
			end
		rescue LLError
			false
		else
			true
		end
	end

private

	def first_operator
		@first ||= FirstOperator.new self
	end

	def follow_operator
		@follow ||= FollowOperator.new self
	end

	def update
		@first = @follow = nil
	end

end

if $0 == __FILE__
  eval DATA.read, nil, $0, __LINE__+4
end

require 'test/unit'

class TestCaseGrammar < Test::Unit::TestCase

	include Grammar::Symbols

	def fifo s
		Set[*s.split('')]
	end

	def test_fifo
		assert_equal Set[], fifo('')
		assert_equal Set[EPSILON, END_OF_INPUT, 'x', 'Y'], fifo('?xY$')
	end

	TEST_GRAMMAR_1 = <<-EOG
S - ABCD
A - a
A -
B - b
B -
C - c
C -
D - S
D -
	EOG

	def test_symbols
		assert EPSILON
		assert END_OF_INPUT
	end

	def test_first_1
		g = Grammar.new TEST_GRAMMAR_1

		f = nil
		assert_nothing_raised { f = g.first }
		assert_equal(Set['a', EPSILON], f['A'])
		assert_equal(Set['b', EPSILON], f['B'])
		assert_equal(Set['c', EPSILON], f['C'])
		assert_equal(Set['a', 'b', 'c', EPSILON], f['D'])
		assert_equal(f['D'], f['S'])
	end

	def test_follow_1
		g = Grammar.new TEST_GRAMMAR_1

		f = nil
		assert_nothing_raised { f = g.follow }
		assert_equal(Set['a', 'b', 'c', END_OF_INPUT], f['A'])
		assert_equal(Set['a', 'b', 'c', END_OF_INPUT], f['B'])
		assert_equal(Set['a', 'b', 'c', END_OF_INPUT], f['C'])
		assert_equal(Set[END_OF_INPUT], f['D'])
		assert_equal(Set[END_OF_INPUT], f['S'])
	end


	TEST_GRAMMAR_2 = <<-EOG
S - Ed
E - EpT
E - EmT
E - T
T - TuF
T - TdF
T - F
F - i
F - n
F - aEz
	EOG

	def test_first_2
		g = Grammar.new TEST_GRAMMAR_2

		f = nil
		assert_nothing_raised { f = g.first }
		assert_equal(Set['a', 'n', 'i'], f['E'])
		assert_equal(Set['a', 'n', 'i'], f['F'])
		assert_equal(Set['a', 'n', 'i'], f['T'])
		assert_equal(Set['a', 'n', 'i'], f['S'])
	end

	def test_follow_2
		g = Grammar.new TEST_GRAMMAR_2

		f = nil
		assert_nothing_raised { f = g.follow }
		assert_equal(Set['m', 'd', 'z', 'p'], f['E'])
		assert_equal(Set['m', 'd', 'z', 'p', 'u'], f['F'])
		assert_equal(Set['m', 'd', 'z', 'p', 'u'], f['T'])
		assert_equal(Set[END_OF_INPUT], f['S'])
	end

	LLError = Grammar::LLError

	TEST_GRAMMAR_3 = <<-EOG
E - TD
D - pTD
D -
T - FS
S - uFS
S -
S - p
F - aEz
F - i
	EOG

	NoError = Class.new(Exception)

	def test_first_3
		g = Grammar.new TEST_GRAMMAR_3

		# Grammar 3 is LL(1), so all first-sets must be disjoint.
		f = nil
		assert_nothing_raised { f = g.first }
		assert_equal(Set['a', 'i'], f['E'])
		assert_equal(Set[EPSILON, 'p'], f['D'])
		assert_equal(Set['a', 'i'], f['F'])
		assert_equal(Set['a', 'i'], f['T'])
		assert_equal(Set[EPSILON, 'u', 'p'], f['S'])
		for m in g.meta_symbols
			r = g.rules[m]
			firsts = r.map { |x| f[x] }.to_set
			assert_nothing_raised do
				firsts.inject(Set.new) do |already_used, another_first_set|
					raise LLError, 'not disjoint!' unless already_used.disjoint? another_first_set
					already_used.merge another_first_set
				end
			end
		end
	end

	def test_follow_3
		g = Grammar.new TEST_GRAMMAR_3

		# Grammar 3 is not LL(1), because epsilon is in FIRST(S),
		# but FIRST(S) and FOLLOW(S) are not disjoint.
		f = nil
		assert_nothing_raised { f = g.follow }
		assert_equal(Set['z', END_OF_INPUT], f['E'])
		assert_equal(Set['z', END_OF_INPUT], f['D'])
		assert_equal(Set['z', 'p', 'u', END_OF_INPUT], f['F'])
		assert_equal(Set['p', 'z', END_OF_INPUT], f['T'])
		assert_equal(Set['p', 'z', END_OF_INPUT], f['S'])
		for m in g.meta_symbols
			first_m = g.first[m]
			next unless first_m.include? EPSILON
			assert_raise(m == 'S' ? LLError : NoError) do
				if first_m.disjoint? f[m]
					raise NoError  # this is fun :D
				else
					raise LLError
				end
			end
		end
	end

	TEST_GRAMMAR_3b = <<-EOG
E - TD
D - pTD
D - PTD
D -
T - FS
S - uFS
S -
F - aEz
F - i
P - p
	EOG

	def test_first_3b
		g = Grammar.new TEST_GRAMMAR_3b

		# Grammar 3b is NOT LL(1), since not all first-sets are disjoint.
		f = nil
		assert_nothing_raised { f = g.first }
		assert_equal(Set['a', 'i'], f['E'])
		assert_equal(Set[EPSILON, 'p'], f['D'])
		assert_equal(Set['p'], f['P'])
		assert_equal(Set['a', 'i'], f['F'])
		assert_equal(Set['a', 'i'], f['T'])
		assert_equal(Set[EPSILON, 'u'], f['S'])
		for m in g.meta_symbols
			r = g.rules[m]
			firsts = r.map { |x| f[x] }
			assert_raise(m == 'D' ? LLError : NoError) do
				firsts.inject(Set.new) do |already_used, another_first_set|
					raise LLError, 'not disjoint!' unless already_used.disjoint? another_first_set
					already_used.merge another_first_set
				end
				raise NoError
			end
		end
	end

	def test_follow_3b
		g = Grammar.new TEST_GRAMMAR_3b

		# Although Grammar 3b is NOT LL(1), the FOLLOW-condition is satisfied.
		f = nil
		assert_nothing_raised { f = g.follow }
		assert_equal(fifo('z$'), f['E'], 'E')
		assert_equal(fifo('z$'), f['D'], 'D')
		assert_equal(fifo('ai'), f['P'], 'P')
		assert_equal(fifo('z$pu'), f['F'], 'F')
		assert_equal(fifo('z$p'), f['T'], 'T')
		assert_equal(fifo('z$p'), f['S'], 'S')
		for m in g.meta_symbols
			first_m = g.first[m]
			next unless first_m.include? EPSILON
			assert_raise(NoError) do
				if first_m.disjoint? f[m]
					raise NoError  # this is fun :D
				else
					raise LLError
				end
			end
		end
	end

	def test_ll1?
		assert_equal false, Grammar.new(TEST_GRAMMAR_3).ll1?, 'Grammar 3'
		assert_equal false, Grammar.new(TEST_GRAMMAR_3b).ll1?, 'Grammar 3b'
	end

	def test_new
		assert_nothing_raised { Grammar.new '' }
		assert_nothing_raised { Grammar.new TEST_GRAMMAR_1 }
		assert_nothing_raised { Grammar.new TEST_GRAMMAR_2 }
		assert_nothing_raised { Grammar.new TEST_GRAMMAR_3 }
		assert_nothing_raised { Grammar.new TEST_GRAMMAR_1 + TEST_GRAMMAR_2 + TEST_GRAMMAR_3 }
		assert_raise(ArgumentError) { Grammar.new 'S - ?' }
	end
end

# vim:foldmethod=syntax

#!/usr/bin/env ruby

require 'fox12'

include Fox

class Window < FXMainWindow
	def initialize(app)
		super(app, app.appName + ": First Set Calculation", nil, nil, DECOR_ALL, 0, 0, 800, 600, 0, 0)

		# {{{ menubar
		menubar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)

		filemenu = FXMenuPane.new(self)

		FXMenuCommand.new(filemenu, "&Start\tCtl-S\tStart the application.", nil, getApp()).connect(SEL_COMMAND, method(:start))
		FXMenuCommand.new(filemenu, "&Quit\tAlt-F4\tQuit the application.", nil, getApp(), FXApp::ID_QUIT)
		FXMenuTitle.new(menubar, "&File", nil, filemenu)
		# }}} menubar

		# {{{ statusbar
		@statusbar = FXStatusBar.new(self, LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X|STATUSBAR_WITH_DRAGCORNER)
		# }}} statusbar

		# {{{ window content
		horizontalsplitt = FXSplitter.new(self, SPLITTER_VERTICAL|LAYOUT_SIDE_TOP|LAYOUT_FILL)


		@productions = FXList.new(horizontalsplitt, nil, 0, LAYOUT_SIDE_TOP|LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT|LIST_SINGLESELECT)
		@productions.height = 100

		@result = FXTable.new(horizontalsplitt, nil, 0, LAYOUT_FILL)
		@result.height = 200
		@result.setTableSize(2, 2, false)
		@result.rowHeaderWidth = 0

		header = @result.columnHeader
		header.setItemText 0, 'X'
		header.setItemText 1, 'FIRST(X)'
		for item in header
			item.justification = FXHeaderItem::CENTER_X
		end

		@debug = FXText.new(horizontalsplitt, nil, 0, LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT)
		@debug.height = 200

		# }}} window content
	end

	def load_grammar grammar
		@tracer = FirstTracer.new(self)
		@grammar = Grammar.new grammar, @tracer
		@rules_indexes = Hash.new
		@grammar.rules.each_with_index do |rule, i|
			@productions.appendItem rule.inspect
			@rules_indexes[rule] = i
		end
	end

	def create
		super
		show(PLACEMENT_SCREEN)
	end

	def rule rule
		@productions.selectItem @rules_indexes[rule]
		sleep 0.1
	end

	def iterate i
		setTitle i.to_s
		sleep 0.1
	end

	def missing what
		@debug.appendText what + "\n"
		sleep 0.1
	end

	def start sender, sel, pointer
		Thread.new do
			begin
				@grammar.first
			rescue => boom
				@debug.appendText [boom.to_s, *boom.backtrace].join("\n")
			end
		end
	end

end

$: << 'grammar'
require 'grammar'

require 'first_tracer'

app = FXApp.new("Shinobu", "cYcnus")

# fenster erzeugen
window = Window.new app

unless ARGV.empty?
	grammar = File.read(ARGV.first)
else
	grammar = <<-EOG1
Z --> S
S --> Sb
S --> bAa
A --> aSc
A --> a
A --> aSb
	EOG1
end

window.load_grammar grammar

app.create
app.run

require 'erb'
require 'ftools'
require 'yaml'
require 'redcloth'

module WhyTheLuckyStiff
	class Book
		attr_accessor :author, :title, :terms, :image, :teaser,
			:chapters, :expansion_paks, :encoding, :credits
		def [] x
			@lang.fetch(x) do
				warn warning = "[not translated: '#{x}'!]"
				warning
			end
		end
	end

	def Book::load( file_name )
		YAML::load( File.open( file_name ) )
	end

	class Section
		attr_accessor :index, :header, :content
		def initialize( i, h, c )
			@index, @header, @content = i, h, RedCloth::new( c.to_s )
		end
	end

	class Sidebar
		attr_accessor :title, :content
	end

	YAML::add_domain_type( 'whytheluckystiff.net,2003', 'sidebar' ) do |taguri, val|
		YAML::object_maker( Sidebar, 'title' => val.keys.first, 'content' => RedCloth::new( val.values.first ) )
	end
	class Chapter
		attr_accessor :index, :title, :sections
		def initialize( i, t, sects )
			@index = i
			@title = t
			i = 0
			@sections = sects.collect do |s|
				if s.respond_to?( :keys )
					i += 1
					Section.new( i, s.keys.first, s.values.first )
				else
					s
				end
			end
		end
	end

	YAML::add_domain_type( 'whytheluckystiff.net,2003', 'book' ) do |taguri, val|
		['chapters', 'expansion_paks'].each do |chaptype|
			i = 0
			val[chaptype].collect! do |c|
				i += 1
				Chapter::new( i, c.keys.first, c.values.first )
			end
		end
		val['teaser'].collect! do |t|
			Section::new( 1, t.keys.first, t.values.first )
		end
		val['terms'] = RedCloth::new( val['terms'] )
		YAML::object_maker( Book, val )
	end

	class Image
		attr_accessor :file_name
	end

	YAML::add_domain_type( 'whytheluckystiff.net,2003', 'img' ) do |taguri, val|
		YAML::object_maker( Image, 'file_name' => "i/" + val )
	end
end

#
# Convert the book to HTML
#
if __FILE__ == $0
	unless ARGV[0]
		puts "Usage: #{$0} [/path/to/save/html]"
		exit
	end

	site_path = ARGV[0]
	book = WhyTheLuckyStiff::Book::load( 'poignant.yml' )
	chapter = nil

	# Write index page
	index_tpl = ERB::new( File.open( 'index.erb' ).read )
	File.open( File.join( site_path, 'index.html' ), 'w' ) do |out|
		out << index_tpl.result
	end

	book.chapters = book.chapters[0,3] if ARGV.include? '-fast'

	# Write chapter pages
	chapter_tpl = ERB::new( File.open( 'chapter.erb' ).read )
	book.chapters.each do |chapter|
		File.open( File.join( site_path, "chapter-#{ chapter.index }.html" ), 'w' ) do |out|
			out << chapter_tpl.result
		end
	end
	exit if ARGV.include? '-fast'

	# Write expansion pak pages
	expak_tpl = ERB::new( File.open( 'expansion-pak.erb' ).read )
	book.expansion_paks.each do |pak|
		File.open( File.join( site_path, "expansion-pak-#{ pak.index }.html" ), 'w' ) do |out|
			out << expak_tpl.result( binding )
		end
	end

	# Write printable version
	print_tpl = ERB::new( File.open( 'print.erb' ).read )
	File.open( File.join( site_path, "print.html" ), 'w' ) do |out|
		out << print_tpl.result
	end

	# Copy css + images into site
	copy_list = ["guide.css"] +
		Dir["i/*"].find_all { |image| image =~ /\.(gif|jpg|png)$/ }

	File.makedirs( File.join( site_path, "i" ) )
	copy_list.each do |copy_file|
		File.copy( copy_file, File.join( site_path, copy_file ) )
	end
end

#!/usr/bin/env ruby

require 'fox'
begin
  require 'opengl'
rescue LoadError
  require 'fox/missingdep'
  MSG = <<EOM
  Sorry, this example depends on the OpenGL extension. Please
  check the Ruby Application Archives for an appropriate
  download site.
EOM
  missingDependency(MSG)
end


include Fox
include Math

Deg2Rad = Math::PI / 180

D_MAX = 6
SQUARE_SIZE = 2.0 / D_MAX
SQUARE_DISTANCE = 4.0 / D_MAX
AMPLITUDE = SQUARE_SIZE
LAMBDA = D_MAX.to_f / 2

class GLTestWindow < FXMainWindow

  # How often our timer will fire (in milliseconds)
  TIMER_INTERVAL = 500

  # Rotate the boxes when a timer message is received
  def onTimeout(sender, sel, ptr)
    @angle += 10.0
#    @size = 0.5 + 0.2 * Math.cos(Deg2Rad * @angle)
    drawScene()
    @timer = getApp().addTimeout(TIMER_INTERVAL, method(:onTimeout))
  end

  # Rotate the boxes when a chore message is received
  def onChore(sender, sel, ptr)
    @angle += 10.0
#    @angle %= 360.0
#    @size = 0.5 + 0.2 * Math.cos(Deg2Rad * @angle)
    drawScene()
    @chore = getApp().addChore(method(:onChore))
  end

  # Draw the GL scene
  def drawScene
    lightPosition = [15.0, 10.0, 5.0, 1.0]
    lightAmbient  = [ 0.1,  0.1, 0.1, 1.0]
    lightDiffuse  = [ 0.9,  0.9, 0.9, 1.0]
    redMaterial   = [ 0.0,  0.0, 1.0, 1.0]
    blueMaterial  = [ 0.0,  1.0, 0.0, 1.0]

    width = @glcanvas.width.to_f
    height = @glcanvas.height.to_f
    aspect = width/height

    # Make context current
    @glcanvas.makeCurrent()

    GL.Viewport(0, 0, @glcanvas.width, @glcanvas.height)

    GL.ClearColor(1.0/256, 0.0, 5.0/256, 1.0)
    GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT)
    GL.Enable(GL::DEPTH_TEST)

    GL.Disable(GL::DITHER)

    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    GLU.Perspective(30.0, aspect, 1.0, 100.0)

    GL.MatrixMode(GL::MODELVIEW)
    GL.LoadIdentity()
    GLU.LookAt(5.0, 10.0, 15.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)

    GL.ShadeModel(GL::SMOOTH)
    GL.Light(GL::LIGHT0, GL::POSITION, lightPosition)
    GL.Light(GL::LIGHT0, GL::AMBIENT, lightAmbient)
    GL.Light(GL::LIGHT0, GL::DIFFUSE, lightDiffuse)
    GL.Enable(GL::LIGHT0)
    GL.Enable(GL::LIGHTING)

    GL.Rotated(0.1*@angle, 0.0, 1.0, 0.0)
    for x in -D_MAX..D_MAX
      for y in -D_MAX..D_MAX
        h1 = (x + y - 2).abs
        h2 = (y - x + 1).abs
        GL.PushMatrix
        c = [1, 0, 0, 1]
        GL.Material(GL::FRONT, GL::AMBIENT, c)
        GL.Material(GL::FRONT, GL::DIFFUSE, c)

        GL.Translated(
          y * SQUARE_DISTANCE,
          AMPLITUDE * h1,
          x * SQUARE_DISTANCE
        )

        GL.Begin(GL::TRIANGLE_STRIP)
          GL.Normal(1.0, 0.0, 0.0)
          GL.Vertex(-SQUARE_SIZE, +SQUARE_SIZE, -SQUARE_SIZE)
          GL.Vertex(-SQUARE_SIZE, +SQUARE_SIZE, +SQUARE_SIZE)
          GL.Vertex(+SQUARE_SIZE, +SQUARE_SIZE, -SQUARE_SIZE)
          GL.Vertex(+SQUARE_SIZE, +SQUARE_SIZE, +SQUARE_SIZE)
        GL.End

        GL.PopMatrix

        GL.PushMatrix
        c = [0, 0, 1, 1]
        GL.Material(GL::FRONT, GL::AMBIENT, c)
        GL.Material(GL::FRONT, GL::DIFFUSE, c)

        GL.Translated(
          y * SQUARE_DISTANCE,
          AMPLITUDE * h2,
          x * SQUARE_DISTANCE
        )

        GL.Begin(GL::TRIANGLE_STRIP)
          GL.Normal(1.0, 0.0, 0.0)
          GL.Vertex(-SQUARE_SIZE, +SQUARE_SIZE, -SQUARE_SIZE)
          GL.Vertex(-SQUARE_SIZE, +SQUARE_SIZE, +SQUARE_SIZE)
          GL.Vertex(+SQUARE_SIZE, +SQUARE_SIZE, -SQUARE_SIZE)
          GL.Vertex(+SQUARE_SIZE, +SQUARE_SIZE, +SQUARE_SIZE)
        GL.End

        GL.PopMatrix

        GL.PushMatrix
        c = [0.0 + (x/10.0), 0.0 + (y/10.0), 0, 1]
        GL.Material(GL::FRONT, GL::AMBIENT, c)
        GL.Material(GL::FRONT, GL::DIFFUSE, c)

        GL.Translated(
          y * SQUARE_DISTANCE,
          0,
          x * SQUARE_DISTANCE
        )

        GL.Begin(GL::TRIANGLE_STRIP)
          GL.Normal(1.0, 0.0, 0.0)
          GL.Vertex(-SQUARE_SIZE, +SQUARE_SIZE, -SQUARE_SIZE)
          GL.Vertex(-SQUARE_SIZE, +SQUARE_SIZE, +SQUARE_SIZE)
          GL.Vertex(+SQUARE_SIZE, +SQUARE_SIZE, -SQUARE_SIZE)
          GL.Vertex(+SQUARE_SIZE, +SQUARE_SIZE, +SQUARE_SIZE)
        GL.End

        GL.PopMatrix
      end
    end

    # Swap if it is double-buffered
    if @glvisual.isDoubleBuffer
      @glcanvas.swapBuffers
    end

    # Make context non-current
    @glcanvas.makeNonCurrent
  end

  def initialize(app)
    # Invoke the base class initializer
    super(app, "OpenGL Test Application", nil, nil, DECOR_ALL, 0, 0, 1024, 768)

    # Construct the main window elements
    frame = FXHorizontalFrame.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X|LAYOUT_FILL_Y)
    frame.padLeft, frame.padRight = 0, 0
    frame.padTop, frame.padBottom = 0, 0

    # Left pane to contain the glcanvas
    glcanvasFrame = FXVerticalFrame.new(frame,
      LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_TOP|LAYOUT_LEFT)
    glcanvasFrame.padLeft, glcanvasFrame.padRight = 10, 10
    glcanvasFrame.padTop, glcanvasFrame.padBottom = 10, 10

    # Label above the glcanvas
    FXLabel.new(glcanvasFrame, "OpenGL Canvas Frame", nil,
      JUSTIFY_CENTER_X|LAYOUT_FILL_X)

    # Horizontal divider line
    FXHorizontalSeparator.new(glcanvasFrame, SEPARATOR_GROOVE|LAYOUT_FILL_X)

    # Drawing glcanvas
    glpanel = FXVerticalFrame.new(glcanvasFrame, (FRAME_SUNKEN|FRAME_THICK|
      LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_TOP|LAYOUT_LEFT))
    glpanel.padLeft, glpanel.padRight = 0, 0
    glpanel.padTop, glpanel.padBottom = 0, 0

    # A visual to draw OpenGL
    @glvisual = FXGLVisual.new(getApp(), VISUAL_DOUBLEBUFFER)

    # Drawing glcanvas
    @glcanvas = FXGLCanvas.new(glpanel, @glvisual, nil, 0,
      LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_TOP|LAYOUT_LEFT)
    @glcanvas.connect(SEL_PAINT) {
      drawScene
    }
    @glcanvas.connect(SEL_CONFIGURE) {
      if @glcanvas.makeCurrent
        GL.Viewport(0, 0, @glcanvas.width, @glcanvas.height)
        @glcanvas.makeNonCurrent
      end
    }

    # Right pane for the buttons
    buttonFrame = FXVerticalFrame.new(frame, LAYOUT_FILL_Y|LAYOUT_TOP|LAYOUT_LEFT)
    buttonFrame.padLeft, buttonFrame.padRight = 10, 10
    buttonFrame.padTop, buttonFrame.padBottom = 10, 10

    # Label above the buttons
    FXLabel.new(buttonFrame, "Button Frame", nil,
      JUSTIFY_CENTER_X|LAYOUT_FILL_X)

    # Horizontal divider line
    FXHorizontalSeparator.new(buttonFrame, SEPARATOR_RIDGE|LAYOUT_FILL_X)

    # Spin according to timer
    spinTimerBtn = FXButton.new(buttonFrame,
      "Spin &Timer\tSpin using interval timers\nNote the app
      blocks until the interal has elapsed...", nil,
      nil, 0, FRAME_THICK|FRAME_RAISED|LAYOUT_FILL_X|LAYOUT_TOP|LAYOUT_LEFT)
    spinTimerBtn.padLeft, spinTimerBtn.padRight = 10, 10
    spinTimerBtn.padTop, spinTimerBtn.padBottom = 5, 5
    spinTimerBtn.connect(SEL_COMMAND) {
      @spinning = true
      @timer = getApp().addTimeout(TIMER_INTERVAL, method(:onTimeout))
    }
    spinTimerBtn.connect(SEL_UPDATE) { |sender, sel, ptr|
      @spinning ? sender.disable : sender.enable
    }

    # Spin according to chore
    spinChoreBtn = FXButton.new(buttonFrame,
      "Spin &Chore\tSpin as fast as possible using chores\nNote even though the
      app is very responsive, it never blocks;\nthere is always something to
      do...", nil,
      nil, 0, FRAME_THICK|FRAME_RAISED|LAYOUT_FILL_X|LAYOUT_TOP|LAYOUT_LEFT)
    spinChoreBtn.padLeft, spinChoreBtn.padRight = 10, 10
    spinChoreBtn.padTop, spinChoreBtn.padBottom = 5, 5
    spinChoreBtn.connect(SEL_COMMAND) {
      @spinning = true
      @chore = getApp().addChore(method(:onChore))
    }
    spinChoreBtn.connect(SEL_UPDATE) { |sender, sel, ptr|
      @spinning ? sender.disable : sender.enable
    }

    # Stop spinning
    stopBtn = FXButton.new(buttonFrame,
      "&Stop Spin\tStop this mad spinning, I'm getting dizzy", nil,
      nil, 0, FRAME_THICK|FRAME_RAISED|LAYOUT_FILL_X|LAYOUT_TOP|LAYOUT_LEFT)
    stopBtn.padLeft, stopBtn.padRight = 10, 10
    stopBtn.padTop, stopBtn.padBottom = 5, 5
    stopBtn.connect(SEL_COMMAND) {
      @spinning = false
      if @timer
        getApp().removeTimeout(@timer)
        @timer = nil
      end
      if @chore
        getApp().removeChore(@chore)
        @chore = nil
      end
    }
    stopBtn.connect(SEL_UPDATE) { |sender, sel, ptr|
      @spinning ? sender.enable : sender.disable
    }

    # Exit button
    exitBtn = FXButton.new(buttonFrame, "&Exit\tExit the application", nil,
      getApp(), FXApp::ID_QUIT,
      FRAME_THICK|FRAME_RAISED|LAYOUT_FILL_X|LAYOUT_TOP|LAYOUT_LEFT)
    exitBtn.padLeft, exitBtn.padRight = 10, 10
    exitBtn.padTop, exitBtn.padBottom = 5, 5

    # Make a tooltip
    FXTooltip.new(getApp())

    # Initialize private variables
    @spinning = false
    @chore = nil
    @timer = nil
    @angle = 0.0
    @size = 0.5
  end

  # Create and initialize
  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

if __FILE__ == $0
  # Construct the application
  application = FXApp.new("GLTest", "FoxTest")

  # To ensure that the chores-based spin will run as fast as possible,
  # we can disable the chore in FXRuby's event loop that tries to schedule
  # other threads. This is OK for this program because there aren't any
  # other Ruby threads running.

  #application.disableThreads

  # Construct the main window
  GLTestWindow.new(application)

  # Create the app's windows
  application.create

  # Run the application
  application.run
end

class Facelet
  attr_accessor :color
  def initialize(color)
    @color = color
  end

  def to_s
    @color
  end
end

class Edge
  attr_accessor :facelets, :colors

  def initialize(facelets)
    @facelets = facelets
    @colors = @facelets.map { |fl| fl.color }
  end

  def apply(edge)
    @facelets.each_with_index { |fl, i|
      fl.color = edge.colors[i]
    }
  end

  def inspect
    "\n%s %s\n%s %s %s" % facelets
  end
end

class Side
  attr_reader :num, :facelets
  attr_accessor :sides

  def initialize(num)
    @num = num
    @sides = []
    @facelets = []
    @fl_by_side = {}
  end

  # facelets & sides
  #     0
  #   0 1 2
  # 3 3 4 5 1
  #   6 7 8
  #     2

  def facelets=(facelets)
    @facelets = facelets.map { |c| Facelet.new(c) }
    init_facelet 0, 3,0
    init_facelet 1, 0
    init_facelet 2, 0,1
    init_facelet 3, 3
    init_facelet 5, 1
    init_facelet 6, 2,3
    init_facelet 7, 2
    init_facelet 8, 1,2
  end

  def <=>(side)
    self.num <=> side.num
  end

  def init_facelet(pos, *side_nums)
    sides = side_nums.map { |num| @sides[num] }.sort
    @fl_by_side[sides] = pos
  end

  def []=(color, *sides)
    @facelets[@fl_by_side[sides.sort]].color = color
  end

  def values_at(*sides)
    sides.map { |sides| @facelets[@fl_by_side[sides.sort]] }
  end

  def inspect(range=nil)
    if range
      @facelets.values_at(*(range.to_a)).join(' ')
    else
      <<-EOS.gsub(/\d/) { |num| @facelets[num.to_i] }.gsub(/[ABCD]/) { |side| @sides[side[0]-?A].num.to_s }
           A
         0 1 2
       D 3 4 5 B
         6 7 8
           C
      EOS
    end
  end

  def get_edge(side)
    trio = (-1..1).map { |x| (side + x) % 4 }
    prev_side, this_side, next_side = @sides.values_at(*trio)
    e = Edge.new(
      self     .values_at(                    [this_side], [this_side, next_side] ) +
      this_side.values_at( [self, prev_side], [self     ], [self,      next_side] )
    )
    #puts 'Edge created for side %d: ' % side + e.inspect
    e
  end

  def turn(dir)
    #p 'turn side %d in %d' % [num, dir]
    edges = (0..3).map { |n| get_edge n }
    for i in 0..3
      edges[i].apply edges[(i-dir) % 4]
    end
  end
end

class Cube
  def initialize
    @sides = []
    %w(left front right back top bottom).each_with_index { |side, i|
      eval("@sides[#{i}] = @#{side} = Side.new(#{i})")
    }
    @left.sides = [@top, @front, @bottom, @back]
    @front.sides = [@top, @right, @bottom, @left]
    @right.sides = [@top, @back, @bottom, @front]
    @back.sides = [@top, @left, @bottom, @right]
    @top.sides = [@back, @right, @front, @left]
    @bottom.sides = [@front, @right, @back, @left]
  end

  def read_facelets(fs)
    pattern = Regexp.new(<<-EOP.gsub(/\w/, '\w').gsub(/\s+/, '\s*'))
        (w w w)
        (w w w)
        (w w w)
(r r r) (g g g) (b b b) (o o o)
(r r r) (g g g) (b b b) (o o o)
(r r r) (g g g) (b b b) (o o o)
        (y y y)
        (y y y)
        (y y y)
    EOP
    md = pattern.match(fs).to_a

    @top.facelets = parse_facelets(md.values_at(1,2,3))
    @left.facelets = parse_facelets(md.values_at(4,8,12))
    @front.facelets = parse_facelets(md.values_at(5,9,13))
    @right.facelets = parse_facelets(md.values_at(6,10,14))
    @back.facelets = parse_facelets(md.values_at(7,11,15))
    @bottom.facelets = parse_facelets(md.values_at(16,17,18))
  end

  def turn(side, dir)
    #p 'turn %d in %d' % [side, dir]
    @sides[side].turn(dir)
    #puts inspect
  end

  def inspect
    <<-EOF.gsub(/(\d):(\d)-(\d)/) { @sides[$1.to_i].inspect(Range.new($2.to_i, $3.to_i)) }
      4:0-2
      4:3-5
      4:6-8
0:0-2 1:0-2 2:0-2 3:0-2
0:3-5 1:3-5 2:3-5 3:3-5
0:6-8 1:6-8 2:6-8 3:6-8
      5:0-2
      5:3-5
      5:6-8
    EOF
  end

private
  def parse_facelets(rows)
    rows.join.delete(' ').split(//)
  end
end

#$stdin = DATA

gets.to_i.times do |i|
  puts "Scenario ##{i+1}:"
  fs = ''
  9.times { fs << gets }
  cube = Cube.new
  cube.read_facelets fs
  gets.to_i.times do |t|
    side, dir = gets.split.map {|s| s.to_i}
    cube.turn(side, dir)
  end
  puts cube.inspect
  puts
end

# 2004 by murphy <korny@cYcnus.de>
# GPL
class Scenario
	class TimePoint
		attr_reader :data
		def initialize *data
			@data = data
		end

		def [] i
			@data[i] or 0
		end

		include Comparable
		def <=> tp
			r = 0
			[@data.size, tp.data.size].max.times do |i|
				r = self[i] <=> tp[i]
				return r if r.nonzero?
			end
			0
		end

		def - tp
			r = []
			[@data.size, tp.data.size].max.times do |i|
				r << self[i] - tp[i]
			end
			r
		end

		def inspect
			# 01/01/1800 00:00:00
			'%02d/%02d/%04d %02d:%02d:%02d' % @data.values_at(1, 2, 0, 3, 4, 5)
		end
	end

	ONE_HOUR = TimePoint.new 0, 0, 0, 1, 0, 0

	APPOINTMENT_PATTERN = /
		( \d{4} ) \s ( \d{2} ) \s ( \d{2} ) \s ( \d{2} ) \s ( \d{2} ) \s ( \d{2} ) \s
		( \d{4} ) \s ( \d{2} ) \s ( \d{2} ) \s ( \d{2} ) \s ( \d{2} ) \s ( \d{2} )
	/x

	def initialize io
		@team_size = io.gets.to_i
		@data = [ [TimePoint.new(1800, 01, 01, 00, 00, 00), @team_size] ]
		@team_size.times do  # each team member
			io.gets.to_i.times do  # each appointment
				m = APPOINTMENT_PATTERN.match io.gets
				@data << [TimePoint.new(*m.captures[0,6].map { |x| x.to_i }), -1]
				@data << [TimePoint.new(*m.captures[6,6].map { |x| x.to_i }), +1]
			end
		end
		@data << [TimePoint.new(2200, 01, 01, 00, 00, 00), -@team_size]
	end

	def print_time_plan
		n = 0
		appointment = nil
		no_appointment = true
		@data.sort_by { |x| x[0] }.each do |x|
			tp, action = *x
			n += action
			# at any time during the meeting, at least two team members need to be there
			# and at most one team member is allowed to be absent
			if n >= 2 and (@team_size - n) <= 1
				appointment ||= tp
			else
				if appointment
					# the meeting should be at least one hour in length
					if TimePoint.new(*(tp - appointment)) >= ONE_HOUR
						puts 'appointment possible from %p to %p' % [appointment, tp]
						no_appointment = false
					end
					appointment = false
				end
			end
		end
		puts 'no appointment possible' if no_appointment
	end
end

# read the data
DATA.gets.to_i.times do |si| # each scenario
	puts 'Scenario #%d:' % (si + 1)
	sc = Scenario.new DATA
	sc.print_time_plan
	puts
end

#__END__
2
3
3
2002 06 28 15 00 00 2002 06 28 18 00 00 TUD Contest Practice Session
2002 06 29 10 00 00 2002 06 29 15 00 00 TUD Contest
2002 11 15 15 00 00 2002 11 17 23 00 00 NWERC Delft
4
2002 06 25 13 30 00 2002 06 25 15 30 00 FIFA World Cup Semifinal I
2002 06 26 13 30 00 2002 06 26 15 30 00 FIFA World Cup Semifinal II
2002 06 29 13 00 00 2002 06 29 15 00 00 FIFA World Cup Third Place
2002 06 30 13 00 00 2002 06 30 15 00 00 FIFA World Cup Final
1
2002 06 01 00 00 00 2002 06 29 18 00 00 Preparation of Problem Set
2
1
1800 01 01 00 00 00 2200 01 01 00 00 00 Solving Problem 8
0

require 'token_consts'
require 'symbol'
require 'ctype'
require 'error'

class Fixnum
	# Treat char as a digit and return it's value as Fixnum.
	# Returns nonsense for non-digits.
	# Examples:
	# <code>
	# RUBY_VERSION[0].digit == '1.8.2'[0].digit == 1
	# </code>
	#
	# <code>
	# ?6.digit == 6
	# </code>
	#
	# <code>
	# ?A.digit == 17
	# </code>
	def digit
		self - ?0
	end
end

##
# Stellt einen einfachen Scanner für die lexikalische Analyse der Sprache Pas-0 dar.
#
# @author Andreas Kunert
# Ruby port by murphy
class Scanner

	include TokenConsts

	attr_reader :line, :pos

	# To allow Scanner.new without parameters.
	DUMMY_INPUT = 'dummy file'
	def DUMMY_INPUT.getc
		nil
	end

	##
	# Erzeugt einen Scanner, der als Eingabe das übergebene IO benutzt.
	def initialize input = DUMMY_INPUT
		@line = 1
		@pos = 0

		begin
			@input = input
			@next_char = @input.getc
		rescue IOError  # TODO show the reason!
			Error.ioError
			raise
		end
	end

	##
	# Liest das n chste Zeichen von der Eingabe.
	def read_next_char
		begin
			@pos += 1
			@current_char = @next_char
			@next_char = @input.getc
		rescue IOError
			Error.ioError
			raise
		end
	end

	##
	# Sucht das nächste Symbol, identifiziert es, instantiiert ein entsprechendes
	# PascalSymbol-Objekt und gibt es zurück.
	# @see Symbol
	# @return das gefundene Symbol als PascalSymbol-Objekt
	def get_symbol
		current_symbol = nil
		until current_symbol
			read_next_char

			if @current_char.alpha?
				identifier = @current_char.chr
				while @next_char.alpha? or @next_char.digit?
					identifier << @next_char
					read_next_char
				end
				current_symbol = handle_identifier(identifier.upcase)
			elsif @current_char.digit?
				current_symbol = number
			else
				case @current_char
				when ?\s
					# ignore
				when ?\n
					new_line
				when nil
					current_symbol = PascalSymbol.new EOP
				when ?{
					comment

				when ?:
					if @next_char == ?=
						read_next_char
						current_symbol = PascalSymbol.new BECOMES
					else
						current_symbol = PascalSymbol.new COLON
					end

				when ?<
					if (@next_char == ?=)
						read_next_char
						current_symbol = PascalSymbol.new LEQSY
					elsif (@next_char == ?>)
						read_next_char
						current_symbol = PascalSymbol.new NEQSY
					else
						current_symbol = PascalSymbol.new LSSSY
					end

				when ?>
					if (@next_char == ?=)
						read_next_char
						current_symbol = PascalSymbol.new GEQSY
					else
						current_symbol = PascalSymbol.new GRTSY
					end

				when ?. then current_symbol = PascalSymbol.new PERIOD
				when ?( then current_symbol = PascalSymbol.new LPARENT
				when ?, then current_symbol = PascalSymbol.new COMMA
				when ?* then current_symbol = PascalSymbol.new TIMES
				when ?/ then current_symbol = PascalSymbol.new SLASH
				when ?+ then current_symbol = PascalSymbol.new PLUS
				when ?- then current_symbol = PascalSymbol.new MINUS
				when ?= then current_symbol = PascalSymbol.new EQLSY
				when ?) then current_symbol = PascalSymbol.new RPARENT
				when ?; then current_symbol = PascalSymbol.new SEMICOLON
				else
					Error.error(100, @line, @pos) if @current_char > ?\s
				end
			end
		end
		current_symbol
	end

private
	##
	# Versucht, in dem gegebenen String ein Schlüsselwort zu erkennen.
	# Sollte dabei ein Keyword gefunden werden, so gibt er ein PascalSymbol-Objekt zurück, das
	# das entsprechende Keyword repräsentiert. Ansonsten besteht die Rückgabe aus
	# einem SymbolIdent-Objekt (abgeleitet von PascalSymbol), das den String 1:1 enthält
	# @see symbol
	# @return falls Keyword gefunden, zugehöriges PascalSymbol, sonst SymbolIdent
	def handle_identifier identifier
		if sym = KEYWORD_SYMBOLS[identifier]
			PascalSymbol.new sym
		else
			SymbolIdent.new identifier
		end
	end

	MAXINT = 2**31 - 1
	MAXINT_DIV_10  = MAXINT / 10
	MAXINT_MOD_10  = MAXINT % 10
	##
	# Versucht, aus dem gegebenen Zeichen und den folgenden eine Zahl zusammenzusetzen.
	# Dabei wird der relativ intuitive Algorithmus benutzt, die endgültige Zahl bei
	# jeder weiteren Ziffer mit 10 zu multiplizieren und diese dann mit der Ziffer zu
	# addieren. Sonderfälle bestehen dann nur noch in der Behandlung von reellen Zahlen.
	# <BR>
	# Treten dabei kein Punkt oder ein E auf, so gibt diese Methode ein SymbolIntCon-Objekt
	# zurück, ansonsten (reelle Zahl) ein SymbolRealCon-Objekt. Beide Symbole enthalten
	# jeweils die Zahlwerte.
	# <BR>
	# Anmerkung: Diese Funktion ist mit Hilfe der Java/Ruby-API deutlich leichter zu realisieren.
	# Sie wurde dennoch so implementiert, um den Algorithmus zu demonstrieren
	# @see symbol
	# @return SymbolIntcon- oder SymbolRealcon-Objekt, das den Zahlwert enthält
	def number
		is_integer = true
		integer_too_long = false
		exponent = 0
		exp_counter = -1
		exp_sign = 1

		integer_mantisse = @current_char.digit

		while (@next_char.digit? and integer_mantisse < MAXINT_DIV_10) or
		 (integer_mantisse == MAXINT_DIV_10 and @next_char.digit <= MAXINT_MOD_10)
			integer_mantisse *= 10
			integer_mantisse += @next_char.digit
			read_next_char
		end

		real_mantisse = integer_mantisse

		while @next_char.digit?
			integer_too_long = true
			real_mantisse *= 10
			real_mantisse += @next_char.digit
			read_next_char
		end
		if @next_char == ?.
			read_next_char
			is_integer = false
			unless @next_char.digit?
				Error.error 101, @line, @pos
			end
			while @next_char.digit?
				real_mantisse += @next_char.digit * (10 ** exp_counter)
				read_next_char
				exp_counter -= 1
			end
		end
		if @next_char == ?E
			is_integer = false
			read_next_char
			if @next_char == ?-
				exp_sign = -1
				read_next_char
			end
			unless @next_char.digit?
				Error.error 101, @line, @pos
			end
			while @next_char.digit?
				exponent *= 10
				exponent += @next_char.digit
				read_next_char
			end
		end

		if is_integer
			if integer_too_long
				Error.error 102, @line, @pos
			end
			SymbolIntcon.new integer_mantisse
		else
			SymbolRealcon.new real_mantisse * (10 ** (exp_sign * exponent))
		end
	end

	##
	# Sorgt für ein Überlesen von Kommentaren.
	# Es werden einfach alle Zeichen bis zu einer schließenden Klammer eingelesen
	# und verworfen.
	def comment
		while @current_char != ?}
			forbid_eop
			new_line if @current_char == ?\n
			read_next_char
		end
	end

	def new_line
		@line += 1
		@pos = 0
	end

	def forbid_eop
		if eop?
			Error.error 103, @line, @pos
		end
		exit
	end

	def eop?
		@current_char.nil?
	end
end

##
# Läßt ein Testprogramm ablaufen.
# Dieses erzeugt sich ein Scanner-Objekt und ruft an diesem kontinuierlich bis zum Dateiende
# get_symbol auf.
if $0 == __FILE__
	scan = Scanner.new(File.new(ARGV[0] || 'test.pas'))
	loop do
		c = scan.get_symbol
		puts c
		break if c.typ == TokenConsts::EOP
	end
end

