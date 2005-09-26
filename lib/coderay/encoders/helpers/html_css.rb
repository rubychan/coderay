module CodeRay module Encoders

	class HTML
		class CSS
			
			def initialize stylesheet = TOKENS
				@classes = Hash.new
				parse stylesheet
			end

			def [] *styles
				cl = @classes[styles.first]
				return '' unless cl
				style = false
				1.upto(cl.size + 1) do |offset|
					break if style = cl[styles[offset .. -1]]
				end
				return style
			end
			
		private
			
			CSS_CLASS = /
				( (?:                # $1 = classes
					\s* \. [-\w]+
				)+ )
				\s* \{
				( [^\}]* )           # $2 = style
				\} \s*
			|
				( . )                # $3 = error
			/mx
			def parse stylesheet
				stylesheet.scan CSS_CLASS do |classes, style, error|
					raise "CSS parse error: '#{error}' not recognized" if error
					styles = classes.scan(/[-\w]+/)
					cl = styles.pop
					@classes[cl] ||= Hash.new
					@classes[cl][styles] = style.strip
				end
			end
			
			MAIN = <<-'MAIN'
.code {
	background-color: #FAFAFA;
	border: 1px solid #D1D7DC;
	font-family: 'Courier New', 'Terminal', monospace;
	font-size: 10pt;
	color: black;
	vertical-align: top;
	text-align: left;
	padding: 0px;
}
span.code { white-space: pre; }
.code tt { font-weight: bold; }
.code pre {
	font-size: 10pt;
	margin: 0px 5px;
}
.code .code_table {
	margin: 0px;
}
.code .line_numbers {
	margin: 0px;
	background-color:#DEF; color: #777;
	vertical-align: top;
	text-align: right;
}
.code .code_cell {
	width: 100%;
	background-color:#FAFAFA;
	color: black;
	vertical-align: top;
	text-align: left;
}
.code .no {
	background-color:#DEF;
	color: #777;
	padding: 0px 5px;
	font-weight: normal;
	font-style: normal;
}

.code tt { display: hidden; }

			MAIN

			TOKENS = <<-'TOKENS'
.af { color:#00C; }
.an { color:#007; }
.av { color:#700; }
.aw { color:#C00; }
.bi { color:#509; font-weight:bold; }
.c  { color:#888; }

.ch { color:#04D; /* background-color:#f0f0ff; */ }
.ch .k { color:#04D; }
.ch .dl { color:#039; }

.cl { color:#B06; font-weight:bold; }
.co { color:#036; font-weight:bold; }
.cr { color:#0A0; }
.cv { color:#369; }
.df { color:#099; font-weight:bold; }
.di { color:#088; font-weight:bold; }
.dl { color:black; }
.do { color:#970; }
.ds { color:#D42; font-weight:bold; }
.e  { color:#666; font-weight:bold; }
.er { color:#F00; background-color:#FAA; }
.ex { color:#F00; font-weight:bold; }
.fl { color:#60E; font-weight:bold; }
.fu { color:#06B; font-weight:bold; }
.gv { color:#d70; font-weight:bold; }
.hx { color:#058; font-weight:bold; }
.i  { color:#00D; font-weight:bold; }
.ic { color:#B44; font-weight:bold; }
.in { color:#B2B; font-weight:bold; }
.iv { color:#33B; }
.la { color:#970; font-weight:bold; }
.lv { color:#963; }
.oc { color:#40E; font-weight:bold; }
.on { color:#000; font-weight:bold; }
.pc { color:#038; font-weight:bold; }
.pd { color:#369; font-weight:bold; }
.pp { color:#579; }
.pt { color:#339; font-weight:bold; }
.r  { color:#080; font-weight:bold; }

.rx { background-color:#fff0ff; }
.rx .k { color:#808; }
.rx .dl { color:#404; }
.rx .mod { color:#C2C; }
.rx .fu  { color:#404; font-weight: bold; }

.s  { background-color:#fff0f0; }
.s  .s { background-color:#ffe0e0; }
.s  .s  .s { background-color:#ffd0d0; }
.s  .k { color:#D20; }
.s  .dl { color:#710; }

.sh { background-color:#f0fff0; }
.sh .k { color:#2B2; }
.sh .dl { color:#161; }

.sy { color:#A60; }
.sy .k { color:#A60; }
.sy .dl { color:#630; }

.ta { color:#070; }
.tf { color:#070; font-weight:bold; }
.ts { color:#D70; font-weight:bold; }
.ty { color:#339; font-weight:bold; }
.v  { color:#036; }
.xt { color:#444; }
			TOKENS
			
			DEFAULT_STYLESHEET = MAIN + TOKENS
		
		end
	end
	
end end

if $0 == __FILE__
	require 'pp'
	pp CodeRay::Encoders::HTML::CSS.new
end
