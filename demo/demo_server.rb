# CodeRay dynamic highlighter

unless ARGV.grep(/-[hv]|--(help|version)/).empty?
	puts <<-USAGE
CodeRay Server 0.5
$Id$

Usage:
	1) Start this and your browser.
	2) Go to http://localhost:2468/?<path to the file>
	   and you should get the highlighted version.

Parameters:
	-d     Debug mode; reload CodeRay engine for every file.
	       (prepare for MANY "already initialized" and "method redefined"
	       messages - ingore it.)
	
	...    More to come.
	USAGE
	exit
end

require 'webrick'
require 'pathname'

class << File
	alias dir? directory?
end

require 'erb'
include ERB::Util
def url_decode s
	s.to_s.gsub(/%([0-9a-f]{2})/i) { [$1.hex].pack 'C' }
end

class String
	def to_link name = File.basename(self)
		"<a href=\"?path=#{url_encode self}\">#{name}</a>"
	end
end

require 'coderay'
class CodeRayServlet < WEBrick::HTTPServlet::AbstractServlet

	STYLE = 'style="font-family: sans-serif; color: navy;"'
	BANNER = '<p><img src="http://rd.cYcnus.de/coderay/coderay-banner" style="border: 0" alt="Highlighted by CodeRay"/></p>'

	def do_GET req, res
		q = req.query_string || ''
		args = Hash[*q.scan(/(.*?)=(.*?)(?:&|$)/).flatten].each_value { |v| v.replace url_decode(v) }
		path = args.fetch 'path', '.'
		
		backlinks = '<p>current path: %s<br />' % html_escape(path) +
			(Pathname.new(path) + '..').cleanpath.to_s.to_link('up') + ' - ' +
			'.'.to_link('current') + '</p>'
		
		res.body = 
			if File.dir? path
				path = Pathname.new(path).cleanpath.to_s
				dirs, files = Dir[File.join(path, '*')].sort.partition { |p| File.dir? p }

				page = "<html><head></head><body #{STYLE}>"
				page << backlinks
				
				page << '<dl>'
				page << "<dt>Directories</dt>\n" + dirs.map do |p|
					"<dd>#{p.to_link}</dd>\n"
				end.join << "\n"
				page << "<dt>Files</dt>\n" + files.map do |p|
					"<dd>#{p.to_link}</dd>\n"
				end.join << "\n"
				page << "</dl>\n"
				page << "#{BANNER}</body></html>"
			
			elsif File.exist? path
				if $DEBUG
					$".delete_if { |f| f =~ /coderay/ }
					require 'coderay'
				end
				div = CodeRay.scan_file(path).html :tab_width => 8, :wrap => :div, :hint => :info
				div.replace <<-DIV
	<div #{STYLE}>
		#{backlinks}
#{div}
	</div>
	#{BANNER}
				DIV
				div.page
			end

		res['Content-Type'] = 'text/html'
	end
end

# This port is taken by "qip_msgd" - I don't know that. Do you?
module CodeRay
	PORT = 0xC0DE / 20
end

server = WEBrick::HTTPServer.new :Port => CodeRay::PORT

server.mount '/', CodeRayServlet

server.mount_proc '/version' do |req, res|
	res.body = 'CodeRay::Version = ' + CodeRay::Version
	res['Content-Type'] = "text/plain"
end

trap("INT") { server.shutdown }
server.start
