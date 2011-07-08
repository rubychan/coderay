module CodeRay
module Styles
  
  # A colorful theme using CSS 3 colors (with alpha channel).
  class Alpha < Style

    register_for :alpha

    code_background = 'hsl(0,0%,95%)'
    numbers_background = 'hsl(180,65%,90%)'
    border_color = 'silver'
    normal_color = 'black'

    CSS_MAIN_STYLES = <<-MAIN  # :nodoc:
.CodeRay {
  background-color: #{code_background};
  border: 1px solid #{border_color};
  color: #{normal_color};
}
.CodeRay pre {
  margin: 0px;
}

span.CodeRay { white-space: pre; border: 0px; padding: 2px; }

table.CodeRay { border-collapse: collapse; width: 100%; padding: 2px; }
table.CodeRay td { padding: 2px 4px; vertical-align: top; }

.CodeRay .line_numbers, .CodeRay .no {
  background-color: #{numbers_background};
  color: gray;
  text-align: right;
  -webkit-user-select: none;
  -moz-user-select: none;
  user-select: none;
}
.CodeRay .line_numbers a, .CodeRay .no a {
  background-color: #{numbers_background} !important;
  color: gray !important;
  text-decoration: none !important;
}
.CodeRay .line_numbers a:target, .CodeRay .no a:target { color: blue !important; }
.CodeRay .line_numbers .highlighted, .CodeRay .no .highlighted { color: red !important; }
.CodeRay .line_numbers .highlighted a, .CodeRay .no .highlighted a { color: red !important; }
.CodeRay .no { padding: 0px 4px; }
.CodeRay .line { display: block; float: left; width: 100%; }
.CodeRay .code { width: 100%; }
.CodeRay .code pre { overflow: auto; }
    MAIN

    TOKEN_COLORS = <<-'TOKENS'
.debug { color: white !important; background: blue !important; }

.an { color:#007 }
.at { color:#f08 }
.av { color:#700 }
.bi { color:#509 }
.c  { color:#888 }
.c .dl { color:#444 }
.c .ch { color:#444 }

.ch { color:#D20 }
.ch .k { color:#D20 }
.ch .dl { color:#710 }

.cl { color:#B06; font-weight:bold }
.cm { color:#A08 }
.co { color:#036; font-weight:bold }
.cr { color:#0A0 }
.cv { color:#369 }
.de { color:#B0B }
.df { color:#099; font-weight:bold }
.di { color:#088; font-weight:bold }
.dl { color:black }
.do { color:#970 }
.dt { color:#34b }
.ds { color:#D42; font-weight:bold }
.e  { color:#666 }
.en { color:#800; font-weight:bold }
.er { color:#F00; background-color:#FAA }
.ex { color:#C00; font-weight:bold }
.fl { color:#60E }
.fu { color:#06B; font-weight:bold }
.gv { color:#d70 }
.hx { color:#02b }
.i  { color:#00D }
.ic { color:#B44; font-weight:bold }

.il { background-color: hsla(0,0%,0%,0.1); color: black }
.idl { font-weight: bold; color: #666 }

.im { color:#f00 }
.in { color:#B2B; font-weight:bold }
.iv { color:#33B }
.la { color:#970; font-weight:bold }
.lv { color:#963 }
.ns { color:#707; font-weight:bold }
.oc { color:#40E }
.op { }
.pc { color:#069 }
.pd { color:#369; font-weight:bold }
.pp { color:#579 }
.ps { color:#00C; font-weight:bold }
.pt { color:#0a5; font-weight:bold }
.r  { color:#080; font-weight:bold }
.kw { color:#080; font-weight:bold }

.ke { color: #606 }
.ke .dl { color: #404 }
.ke .ch { color: #60f }
.vl { color: #088; }

.rx { background-color:hsla(300,100%,50%,0.09); }
.rx .k { color:#808 }
.rx .dl { color:#404 }
.rx .mod { color:#C2C }

.s { background-color:hsla(0,100%,50%,0.08); }
.s .k { color: #D20 }
.s .ch { color: #b0b }
.s .dl { color: #710 }
.s .mod { color: #E40 }

.sh { background-color:hsla(120,100%,50%,0.09); }
.sh .k { color:#2B2 }
.sh .dl { color:#161 }

.sy { color:#A60 }
.sy .k { color:#A60 }
.sy .dl { color:#630 }

.ta { color:#070 }
.ts { color:#D70; font-weight:bold }
.ty { color:#339; font-weight:bold }
.v  { color:#037 }
.xt { color:#444 }

.ins { background: hsla(120,100%,50%,0.1) }
.del { background: hsla(0,100%,50%,0.1) }
.chg { color: #bbf; background: #007; }
.head { color: #f8f; background: #505 }
.head .filename { color: white; }

.del .eye { background-color: hsla(0,100%,50%,0.2); border: 1px solid hsla(0,100%,45%,0.5); margin: -1px; border-bottom: none; border-top-left-radius: 5px; border-top-right-radius: 5px; }
.ins .eye { background-color: hsla(120,100%,50%,0.2); border: 1px solid hsla(120,100%,25%,0.5); margin: -1px; border-top: none; border-bottom-left-radius: 5px; border-bottom-right-radius: 5px; }

.ins .ins { color: #0c0; background:transparent; font-weight:bold }
.del .del { color: #c00; background:transparent; font-weight:bold }
.chg .chg { color: #88f }
.head .head { color: #f4f }
    TOKENS

  end

end
end
