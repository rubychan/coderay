module CodeRay
	module Encoders

	class HTML
		
		# This module is included in the output String from thew HTML Encoder.
		#
		# It provides methods like wrap, div, page etc.
		#
		# Remember to use #clone instead of #dup to keep the modules the object was
		# extended with.
		#
		# TODO: more doc.
		module Output

			class << self
				
				# This makes Output look like a class.
				#
				# Example:
				# 
				#  a = Output.new '<span class="co">Code</span>'
				#  a.wrap! :page
				def new string, element = nil
					output = string.clone.extend self
					output.wrapped_in = element
					output
				end
				
				# Raises an exception if an object that doesn't respond to to_str is extended by Output,
				# to prevent users from misuse. Use Module#remove_method to disable.
				def extended o
					warn "The Output module is intended to extend instances of String, not #{o.class}." unless o.respond_to? :to_str
				end

				def page_template_for_css css = :default
					css = CSS::DEFAULT_STYLESHEET if css == :default
					PAGE.apply 'CSS', css
				end

				# Define a new wrapper. This is meta programming.
				def wrapper *wrappers
					wrappers.each do |wrapper|
						define_method wrapper do |*args|
							wrap wrapper, *args
						end
						define_method "#{wrapper}!".to_sym do |*args|  
							wrap! wrapper, *args
						end
					end
				end
			end

			wrapper :div, :span, :page

			def wrapped_in
				@wrapped_in ||= nil
			end
			attr_writer :wrapped_in
			
			def wrapped_in? element
				wrapped_in == element
			end
			
			def wrap_in template
				clone.wrap_in! template
			end

			def wrap_in! template
				Template.wrap! self, template, 'CONTENT'
				self
			end
			
			def wrap! element, *args
				return self if not element or element == wrapped_in
				case element
				when :div
					raise "Can't wrap %p in %p" % [wrapped_in, element] unless wrapped_in? nil
					wrap_in! DIV
				when :span
					raise "Can't wrap %p in %p" % [wrapped_in, element] unless wrapped_in? nil
					wrap_in! SPAN
				when :page
					wrap! :div if wrapped_in? nil
					raise "Can't wrap %p in %p" % [wrapped_in, element] unless wrapped_in? :div
					wrap_in! Output.page_template_for_css
				when nil
					return self
				else
					raise "Unknown value %p for :wrap" % element
				end
				@wrapped_in = element
				self
			end

			def wrap *args
				clone.wrap!(*args)
			end

			def numerize! mode = :table, options = {}
				return self unless mode

				start = options.fetch :line_number_start, DEFAULT_OPTIONS[:line_number_start]
				unless start.is_a? Integer
					raise ArgumentError, "Invalid value %p for :line_number_start; Integer expected." % start
				end
				
				unless NUMERIZABLE_WRAPPINGS.include? options[:wrap]
					raise ArgumentError, "Can't numerize, :wrap must be in %p, but is %p" % [NUMERIZABLE_WRAPPINGS, options[:wrap]]
				end
				
				bold_every = options.fetch :bold_every, DEFAULT_OPTIONS[:bold_every]
				bolding = 
					if bold_every == :no_bolding or bold_every == 0
						proc { |line| line.to_s }
					elsif bold_every.is_a? Integer
						proc do |line|
							if line % bold_every == 0
								"<strong>#{line}</strong>"  # every bold_every-th number in bold
							else
								line.to_s
							end
						end
					else
						raise ArgumentError, "Invalid value %p for :bolding; :no_bolding or Integer expected." % bolding
					end
				
				line_count = count("\n")
				line_count += 1 if self[-1] != ?\n

				case mode				
				when :inline
					max_width = (start + line_count).to_s.size
					line = start
					gsub!(/^/) do
						line_number = bolding.call line
						line += 1
						"<span class=\"no\">#{ line_number.rjust(max_width) }</span>  "
					end
					wrap! :div
					
				when :table
					# This is really ugly.
					# Because even monospace fonts seem to have different heights when bold, 
					# I make the newline bold, both in the code and the line numbers.
					# FIXME Still not working perfect for Mr. Internet Exploder
					line_numbers = (start ... start + line_count).to_a.map(&bolding).join("\n")
					line_numbers << "\n"  # also for Mr. MS Internet Exploder :-/
					line_numbers.gsub!(/\n/) { "<tt>\n</tt>" }
					
					line_numbers_tpl = DIV_TABLE.apply('LINE_NUMBERS', line_numbers)
					gsub!(/\n/) { "<tt>\n</tt>" }
					wrap_in! line_numbers_tpl
					@wrapped_in = :div
					
				else
					raise ArgumentError, "Unknown value %p for mode: :inline or :table expected" % mode
				end

				self
			end

			def numerize *args
				clone.numerize!(*args)
			end

			class Template < String

				def self.wrap! str, template, target
					target = Regexp.new(Regexp.escape("<%#{target}%>"))
					if template =~ target
						str[0,0] = $`
						str << $'
					else
						raise "Template target <%%%p%%> not found" % target
					end
				end
				
				def apply target, replacement
					target = Regexp.new(Regexp.escape("<%#{target}%>"))
					if self =~ target
						Template.new($` + replacement + $')
					else
						raise "Template target <%%%p%%> not found" % target
					end
				end

				module Simple
					def ` str  #`
						Template.new str
					end
				end
			end
			
			extend Template::Simple

#-- don't include the templates in docu
			
			SPAN = `<span class="CodeRay"><%CONTENT%></span>`

			DIV = <<-`DIV`
<div class="CodeRay">
	<div class="code"><pre><%CONTENT%></pre></div>	
</div>
			DIV

			DIV_TABLE = <<-`DIV_TABLE`
<table class="CodeRay"> <tr>
	<td class="line_numbers" title="click to toggle" onclick="with (this.firstChild.style) { display = (display == '') ? 'none' : '' }"><pre><%LINE_NUMBERS%></pre></td>
	<td class="code"><pre title="double click to expand" ondblclick="with (this.style) { overflow = (overflow == 'auto' || overflow == '') ? 'visible' : 'auto' }"><%CONTENT%></pre></td>
</tr> </table>
			DIV_TABLE

			PAGE = <<-`PAGE`
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="de">
<head>
	<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
	<title>CodeRay HTML Encoder Example</title>
	<style type="text/css">
<%CSS%>
	</style>
</head>
<body style="background-color: white;">

<%CONTENT%>
</body>
</html>
			PAGE

		end

	end

end
end
