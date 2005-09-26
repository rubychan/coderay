require 'rubygems'
require_gem 'rubylexer'
require 'rubylexer.rb'

module CodeRay module Scanners

	class RubyLex < Scanner
		
		register_for :rubylex

		class FakeFile < String

			def initialize(*)
				super
				@pos = 0
			end
			
			attr_accessor :pos
			
			def read x
				pos = @pos
				@pos += x
				self[pos ... @pos]
			end

			def getc
				pos = @pos
				@pos += 1
				self[pos]||-1
			end

			def eof?
				@pos == size
			end

			def each_byte
				until eof?
					yield getc
				end
			end
			
			def method_missing meth, *args
				raise NoMethodError, '%s%s' % [meth, args]
			end

		end

	private
		Translate = {
			:ignore => :comment,
			:varname => :ident,
			:number => :integer,
			:ws => :space,
			:escnl => :space,
			:keyword => :reserved,
			:methname => :method,
			:renderexactlystring => :regexp,
			:string => :string,
		}

		def scan_tokens tokens, options
			require 'tempfile'
			Tempfile.open('~coderay_tempfile') do |file|
				file.binmode
				file.write code
				file.rewind
				lexer = RubyLexer.new 'code', file
				loop do
					begin
						tok = lexer.get1token
					rescue => kaboom
						err = <<-EOE
	ERROR!!!
#{kaboom.inspect}
#{kaboom.backtrace.join("\n")}
						EOE
						tokens << [err, :error]
						Kernel.raise
					end
					break if tok.is_a? EoiToken
					next if tok.is_a? FileAndLineToken
					kind = tok.class.name[/(.*?)Token$/,1].downcase.to_sym
					kind = Translate.fetch kind, kind
					text = tok.ident
					case kind
					when :hereplaceholder
						text = tok.ender
						kind = :string
					when :herebody, :outlinedherebody
						text = tok.ident.ident
						kind = :string
					end
					text = text.inspect unless text.is_a? String
					p token if kind == :error
					tokens << [text.dup, kind]
				end
			end
			tokens
		end
	end

end end
