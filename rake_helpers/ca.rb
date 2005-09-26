#!c:/ruby/bin/rubyw
# Hy-Ca 0.2 by murphy

module Hy
	def self.ca str
		str.gsub! %r-^(\s*)(?://)(.*)?-, '\1/*\2*/'
		str.gsub! %r-\s*/\*.*?\*/\n?-m, ''
		str.gsub!(/<<(.*?)>>/m) do
			begin
				eval $1
				''
			rescue Exception => boom
				"<<\n#{boom}\n>>"
			end
		end
		
		str.gsub!(/\$([\w_]+)/m) do
			begin
				eval $1
			rescue
				''
			end
		end

		str
	end
end

begin
	if file = ENV['PATH_TRANSLATED']
		puts "Content-Type: text/css"
		puts
		ca = File.read file
	else
		ca = ARGF.read
	end
	print Hy.ca(ca)
rescue => boom
	p boom
end
