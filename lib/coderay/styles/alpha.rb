module CodeRay
module Styles
  
  # A colorful theme using CSS 3 colors (with alpha channel).
  class Alpha < Style

    register_for :alpha

    code_background = '#f8f8f8'
    numbers_background = '#def'
    border_color = 'silver'
    normal_color = '#000'

    CSS_MAIN_STYLES = <<-MAIN  # :nodoc:
.CodeRay {
  background-color: #{code_background};
  border: 1px solid #{border_color};
  font-family: 'Courier New', 'Terminal', monospace;
  color: #{normal_color};
}
.CodeRay pre { margin: 0px; }

span.CodeRay { white-space: pre; border: 0px; padding: 2px; }

table.CodeRay { border-collapse: collapse; width: 100%; padding: 2px; }
table.CodeRay td { padding: 2px 4px; vertical-align: top; }

.CodeRay .line_numbers, .CodeRay .no {
  background-color: #{numbers_background};
  color: gray;
  text-align: right;
}
.CodeRay .line_numbers a:target, .CodeRay .no a:target { color: blue; }
.CodeRay .line_numbers .highlighted, .CodeRay .no .highlighted { color: red; }
.CodeRay .no { padding: 0px 4px; }
.CodeRay .code { width: 100%; }
.CodeRay .code pre { overflow: auto; }
    MAIN

    TOKEN_COLORS = <<-'TOKENS'
.debug { color:white ! important; background:blue ! important; }

.an { color:#007 }
.at { color:#f08 }
.av { color:#700 }
.bi { color:#509; font-weight:bold }
.c  { color:#888; }
.c .dl { color:#444; }
.c .ch { color:#444; }

.ch { color:#04D }
.ch .k { color:#04D }
.ch .dl { color:#039 }

.cl { color:#B06; font-weight:bold }
.cm { color:#A08; font-weight:bold }
.co { color:#036; font-weight:bold }
.cr { color:#0A0 }
.cv { color:#369 }
.de { color:#B0B; }
.df { color:#099; font-weight:bold }
.di { color:#088; font-weight:bold }
.dl { color:black }
.do { color:#970 }
.dt { color:#34b }
.ds { color:#D42; font-weight:bold }
.e  { color:#666; font-weight:bold }
.en { color:#800; font-weight:bold }
.er { color:#F00; background-color:#FAA }
.ex { color:#C00; font-weight:bold }
.fl { color:#60E; font-weight:bold }
.fu { color:#06B; font-weight:bold }
.gv { color:#d70; font-weight:bold }
.hx { color:#058; font-weight:bold }
.i  { color:#00D; font-weight:bold }
.ic { color:#B44; font-weight:bold }

.il { background-color: hsla(0,0%,0%,0.1); color: black }
.il .idl { font-weight: bold; color: #666 }
.idl { font-weight: bold; color: #666; }

.im { color:#f00; }
.in { color:#B2B; font-weight:bold }
.iv { color:#33B }
.la { color:#970; font-weight:bold }
.lv { color:#963 }
.ns { color:#707; font-weight:bold }
.oc { color:#40E; font-weight:bold }
.op { }
.pc { color:#058; font-weight:bold }
.pd { color:#369; font-weight:bold }
.pp { color:#579; }
.ps { color:#00C; font-weight:bold }
.pt { color:#074; font-weight:bold }
.r, .kw  { color:#080; font-weight:bold }

.ke { color: #808; }
.ke .dl { color: #606; }
.ke .ch { color: #80f; }
.vl { color: #088; }

.rx { background-color:hsla(300,100%,50%,0.1); color:#808 }
.rx .k { }
.rx .dl { color:#404 }
.rx .mod { color:#C2C }
.rx .fu  { color:#404; font-weight: bold }

.s { background-color:hsla(0,100%,50%,0.1); color: #D20; }
.s .k { }
.s .ch { color: #b0b; }
.s .dl { color: #710; }

.sh { background-color:hsla(120,100%,50%,0.1); color:#2B2 }
.sh .k { }
.sh .dl { color:#161 }

.sy { color:#A60 }
.sy .k { color:#A60 }
.sy .dl { color:#630 }

.ta { color:#070 }
.ts { color:#D70; font-weight:bold }
.ty { color:#339; font-weight:bold }
.v  { color:#036 }
.xt { color:#444 }

.ins { background: #afa; }
.del { background: #faa; }
.chg { color: #aaf; background: #007; }
.head { color: #f8f; background: #505 }
.head .filename { color: white; }

.ins .ins { color: #080; font-weight:bold }
.del .del { color: #800; font-weight:bold }
.chg .chg { color: #66f; }
.head .head { color: #f4f; }
    TOKENS

  end

end
end