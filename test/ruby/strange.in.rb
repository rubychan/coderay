a.each{|el|anz[el]=anz[el]?anz[el]+1:1}
while x<10000
#a bis f dienen dazu die Nachbarschaft festzulegen. Man stelle sich die #Zahl von 1 bis 64 im Binärcode vor 1 bedeutet an 0 aus
  b=(p[x]%32)/16<1 ? 0 : 1

  (x-102>=0? n[x-102].to_i : 0)*a+(x-101>=0?n[x-101].to_i : 0)*e+n[x-100].to_i+(x-99>=0? n[x-99].to_i : 0)*f+(x-98>=0? n[x-98].to_i : 0)*a+
  n[x+199].to_i*b+n[x+200].to_i*d+n[x+201].to_i*b

#und die Ausgabe folgt
g=%w{}
x=0

=begin
class Hello
  @hi   #class-instance-variable
  self <<class
    attr_accessor :hi
  end
end
=end

while x<100
 puts"#{g[x]}"
 x+=1
end

puts""
sleep(10)

1E1E1
puts 30.send(:/, 5) # prints 6

"instance variables can be #@included, #@@class_variables\n and #$globals as well."
`instance variables can be #@included, #@@class_variables\n and #$globals as well.`
'instance variables can be #@included, #@@class_variables\n and #$globals as well.'
/instance variables can be #@included, #@@class_variables\n and #$globals as well./mousenix
:"instance variables can be #@included, #@@class_variables\n and #$globals as well."
:'instance variables can be #@included, #@@class_variables\n and #$globals as well.'
%'instance variables can be #@included, #@@class_variables\n and #$globals as well.'
%q'instance variables can be #@included, #@@class_variables\n and #$globals as well.'
%Q'instance variables can be #@included, #@@class_variables\n and #$globals as well.'
%w'instance variables can be #@included, #@@class_variables\n and #$globals as well.'
%W'instance variables can be #@included, #@@class_variables\n and #$globals as well.'
%s'instance variables can be #@included, #@@class_variables\n and #$globals as well.'
%r'instance variables can be #@included, #@@class_variables\n and #$globals as well.'
%x'instance variables can be #@included, #@@class_variables\n and #$globals as well.'

#%W[ but #@0illegal_values look strange.]

%s#ruby allows strange#{constructs}
%s#ruby allows strange#$constructs
%s#ruby allows strange#@@constructs

%r\VERY STRANGE!\x00
%x\VERY STRANGE!\x00

~%r#<XMP>#i .. ~%r#</XMP>#i;

a = <<"EOF"
This is a multiline #$here document
terminated by EOF on a line by itself
EOF

a = <<'EOF'
This is a multiline #$here document
terminated by EOF on a line by itself
EOF

b=(p[x] %32)/16<1 ? 0 : 1

#<<""
<<"X"
#{test}
#@bla
#die suppe!!!
\xfffff


super <<-EOE % [
			EOE

<<X
X
X
%s(uninter\)pre\ted)
%q(uninter\)pre\ted)
%Q(inter\)pre\ted)
:"inter\)pre\ted"
:'uninter\'pre\ted'

%q[haha! [nesting [rocks] ] ! ]

%Q[hehe! #{ %Q]nesting #{"really"} rocks] } ! ]

"but it #{<<may} break"
the code.
may

# this is a known bug.
p <<this
but it may break #{<<that}
code.
that
this
that

##################################################################
class                                                  NP
def  initialize a=@p=[], b=@b=[];                      end
def +@;@b<<1;b2c end;def-@;@b<<0;b2c                   end
def  b2c;if @b.size==8;c=0;@b.each{|b|c<<=1;c|=b};send(
     'lave'.reverse,(@p.join))if c==0;@p<<c.chr;@b=[] end
     self end end ; begin _ = NP.new                   end
c
# ^ This is a bug :(

# The Programming Language `NegaPosi'
+-+--++----+--+-+++--+-------+--++--+++---+-+++-+-+-+++-----+++-_
+--++++--+---++-+-+-+++--+--+-+------+--++++-++---++-++---++-++-_
+++--++-+-+--++--+++--+------+----+--++--+++-++-+----++------+--_
-+-+----+++--+--+----+--+--+-++-++--+++-++++-++-----+-+-+----++-_
---------+-+----                                                _
##################################################################


# date: 03/18/2004
# title: primes less than 1000 ( 2005 Obfuscated Ruby Contest )
# author: Jim Lawless
# email: jimbo at radiks dotski net
# comments: This program will display all positive prime integers
#           less than 1000.  Program licens is the same as the Ruby
#           license ( http://www.ruby-lang.org/en/LICENSE.txt )

   $e=""

def a()
   $a=$a+1
end

def b()
   $a=$a+5
end

def c()
   $e=$e+$a.chr
end

def d()
   $a=10
end

def e()
   $a=$a+16
end

d;e;b;a;a;a;a;a;c;d;e;e;e;e;e;e;b;a;a;a;a;c;d;e;e;e;a;a;a;c;d;e;e;b;b;
a;c;d;c;d;e;e;e;e;e;e;b;b;a;a;a;c;d;e;e;e;e;e;b;b;a;a;a;a;c;d;e;e;e;e;
e;b;b;a;a;a;a;a;c;d;e;e;e;e;e;e;a;a;c;d;e;e;e;e;e;b;b;a;c;d;e;b;a;c;
d;e;b;a;a;a;a;a;c;d;e;e;e;e;e;e;b;a;a;a;a;c;d;e;e;e;a;a;c;d;e;e;b;a;a;
c;d;e;e;b;a;c;d;e;e;b;a;c;d;e;e;b;a;c;d;c;d;e;b;a;a;a;a;a;c;d;e;e;e;e;e;b;
b;a;a;a;a;a;c;d;e;e;e;a;a;a;c;d;e;e;b;a;a;a;c;d;c;d;e;b;a;a;a;a;a;c;d;e;
e;e;e;e;b;b;a;a;c;d;e;e;e;e;e;e;a;a;a;a;a;c;d;e;e;e;e;e;e;b;b;a;c;
d;e;e;e;e;e;e;a;a;a;a;c;d;e;e;e;e;e;b;a;a;a;a;a;c;d;e;e;e;a;a;a;c;d;e;
e;b;a;c;d;c;d;e;e;e;e;e;e;b;b;a;a;a;c;d;e;e;e;e;e;b;b;a;a;a;a;c;d;e;e;
e;e;e;b;b;a;a;a;a;a;c;d;e;e;e;e;e;e;a;a;c;d;e;e;e;e;e;b;b;a;c;d;e;b;
a;c;d;e;b;a;a;a;a;a;c;d;e;e;e;e;e;b;b;a;a;a;a;a;c;d;e;e;e;a;a;c;d;e;b;
a;a;a;a;a;c;d;e;e;e;e;e;e;b;a;a;a;a;c;d;e;b;a;c;d;c;d;e;e;e;e;e;b;b;a;
a;a;a;a;c;d;e;e;e;e;e;b;b;a;a;c;d;e;b;b;a;a;a;a;c;d;e;b;a;c;d;e;b;b;a;
a;a;a;c;d;e;b;a;a;a;a;a;c;d;e;e;e;e;e;e;b;a;a;a;a;c;d;e;e;a;a;a;a;c;
d;e;e;e;e;e;e;a;a;a;c;d;e;e;e;e;e;e;a;a;a;a;a;c;d;e;e;e;e;e;b;a;a;a;
a;a;c;d;e;e;e;e;e;e;b;b;a;c;d;e;e;e;e;e;e;a;a;c;d;e;e;e;e;e;e;a;a;a;
a;a;c;d;e;b;b;a;a;a;a;c;d;e;b;a;a;a;a;a;c;d;e;e;e;e;e;b;b;a;a;a;a;a;
c;d;e;b;b;a;a;a;a;a;c;d;e;b;b;a;a;a;a;a;c;d;e;e;e;a;a;a;c;d;e;e;e;a;a;
a;c;d;e;e;b;a;c;d;e;b;b;a;a;a;a;a;c;d;e;b;a;c;d;c;d;e;b;a;a;a;a;a;c;d;e;e;
e;e;e;b;b;a;a;c;d;e;e;e;e;e;e;a;a;a;a;a;c;d;e;e;e;e;e;e;b;b;a;c;d;e;
e;e;e;e;e;a;a;a;a;c;d;e;e;e;e;e;b;a;a;a;a;a;c;d;e;e;e;a;a;a;c;d;e;e;
b;a;a;c;d;c;d;e;e;e;e;e;b;a;a;a;c;d;e;e;e;e;e;e;b;a;a;a;c;d;e;e;e;e;e;
b;b;a;c;d;e;e;e;e;e;b;a;a;c;d;e;e;e;e;e;e;a;c;d;c;d;e;e;e;e;e;b;b;a;c;
d;e;e;e;e;e;e;a;a;a;a;c;d;e;e;e;e;e;b;a;a;a;a;a;c;d;c;d;e;b;a;a;a;a;a;
c;d;e;e;e;e;e;b;b;a;a;a;a;a;c;d;e;e;e;a;a;a;c;d;e;b;a;a;a;a;a;c;d;e;e;
e;e;e;b;b;a;a;a;a;a;c;d;e;e;a;c;d;e;e;b;a;a;c;d;c;d;e;e;e;e;e;b;b;a;a;
a;a;a;c;d;e;e;e;e;e;b;b;a;a;c;d;e;b;a;c;d;e;b;b;a;a;a;a;c;d;e;b;b;a;a;
a;a;c;d;e;b;a;a;a;a;a;c;d;e;e;e;e;e;b;b;a;a;a;a;a;c;d;e;b;b;b;a;c;d;e;
b;a;a;a;a;a;c;d;e;e;e;e;e;b;b;a;a;a;a;a;c;d;e;b;b;a;a;a;a;a;c;d;e;e;
e;a;a;a;a;c;d;e;b;a;a;a;a;a;c;d;e;e;e;e;e;e;b;a;a;a;a;c;d;e;b;b;a;a;
a;a;a;c;d;c;d;e;e;e;e;e;b;a;a;a;c;d;e;e;e;e;e;e;b;a;a;a;c;d;e;e;e;e;e;
b;b;a;c;d;e;e;e;e;e;b;a;a;c;d;e;e;e;e;e;e;a;c;d;c;d;e;e;e;e;e;b;b;a;c;
d;e;e;e;e;e;e;a;a;a;a;c;d;e;e;e;e;e;b;a;a;a;a;a;c;d;c;d;e;e;e;e;e;b;b;
a;c;d;e;e;e;e;e;e;a;a;a;a;c;d;e;e;e;e;e;b;a;a;a;a;a;c;d;c;d;e;e;e;e;e;
b;b;a;a;a;a;a;c;d;e;e;e;e;e;b;b;a;a;c;d;e;b;b;a;a;a;a;c;d;e;b;a;a;a;
a;a;c;d;e;e;e;e;e;b;b;a;a;c;d;e;e;e;e;e;e;a;a;a;a;a;c;d;e;e;e;e;e;e;
b;b;a;c;d;e;e;e;e;e;e;a;a;a;a;c;d;e;e;e;e;e;b;a;a;a;a;a;c;d;e;e;e;a;
a;a;c;d;e;e;e;a;a;a;c;d;e;e;b;a;c;d;e;b;b;a;a;a;a;a;c;d;e;b;a;c;d;c;d;e;e;
e;e;e;e;b;a;c;d;e;e;e;e;e;e;b;b;a;c;d;e;e;e;e;e;e;b;a;a;a;a;a;c;d;e;
e;e;e;e;e;b;a;a;a;a;c;d;e;b;a;c;d;e;b;a;a;a;c;d;e;b;a;a;a;a;c;d;e;e;e;
e;e;e;e;a;c;d;e;b;a;a;a;a;a;c;d;e;e;e;e;e;e;b;a;a;a;a;c;d;e;e;e;e;e;
e;e;a;a;a;c;d;e;b;a;c;d;e;e;e;e;e;b;b;a;a;a;a;a;c;d;e;e;e;e;e;e;b;a;
a;a;a;c;d;e;b;a;c;d;e;e;e;e;e;e;b;a;c;d;e;e;e;e;e;e;b;a;a;a;c;d;e;e;e;
e;e;b;b;a;a;a;a;a;c;d;e;e;e;e;e;e;a;a;a;c;d;e;e;e;e;e;b;b;a;c;d;e;b;
a;a;a;c;d;c;d;e;e;e;e;e;b;b;a;c;d;e;e;e;e;e;e;a;a;a;a;c;d;e;e;e;e;e;b;
a;a;a;a;a;c;d;c;d;e;b;a;a;a;a;a;c;d;e;e;e;e;e;e;b;a;a;a;a;c;d;e;b;a;c;
d;e;e;e;a;a;a;c;d;e;b;a;c;d;e;b;a;a;a;a;a;c;d;e;e;e;e;e;e;b;a;a;a;a;c;
d;e;b;a;c;d;e;e;a;c;d;e;b;a;c;d;e;e;b;a;a;c;d;c;d;e;e;e;e;e;b;b;a;c;d;e;e;e;
e;e;e;a;a;a;a;c;d;e;e;e;e;e;b;a;a;a;a;a;c;d;c;d;e;b;a;c;d;e;b;a;c;d;e;b;
a;c;d;e;b;a;c;d;e;b;a;c;d;e;b;a;c;d;e;b;a;c;eval $e

$_=%{q,l= %w{Ruby\\ Quiz Loader}
n,p,a= "\#{q.do#{%w{w a n c}.sort{|o,t|t<=>o}}se.d\x65l\x65t\x65(' ')}.com/",
{"bmJzcA==\n".\x75np\x61ck("m")[0]=>" ","bHQ=\n".\x75np\x61ck((?n-1).chr)[0]=>
:<,"Z3Q=\n".\x75np\x61ck("m")[0]=>:>,"YW1w\n".\x75np\x61ck((?l+1).chr)[0]=>:&},
[[/^\\s+<\\/div>.+/m,""],[/^\\s+/,""],[/\n/,"\n\n"],[/<br \\/>/,"\n"],
[/<hr \\/>/,"-="*40],[/<[^>]+>/,""],[/^ruby/,""],[/\n{3,}/,"\n\n"]];p\165ts"
\#{l[0..-3]}ing...\n\n";send(Kernel.methods.find_all{|x|x[0]==?e}[-1],
"re\#{q[5...8].downcase}re '111112101110-117114105'.scan(/-|\\\\d{3}/).
inject(''){|m,v|v.length>1?m+v.to_i.chr: m+v}");o#{%w{e P}.sort.join.downcase
}n("http://www.\#{n}"){|w|$F=w.read.sc\x61n(/li>.+?"([^"]+)..([^<]+)/)};\160uts\
"\#{q}\n\n";$F.\145\141ch{|e|i=e[0][/\\d+/];s="%2s.  %s"%[i,e[1]];i.to_i%2==0 ?
\160ut\x73(s) : #{%w{s p}[-1]}rint("%-38s  "%s)};p\x72\x69\x6et"\n?  ";e\x76al(
['puts"\n\#{l[0..3]}ing...\n\n"','$c=gets.chomp.to_i'].sort.join(";"));#{111.chr
}pen("http://www.\#{n}"+$F[$c-1][0]){|n|$_=n.read[/^\\s+<span.+/m];#{('a'.."z").
to_a[10-5*2]}.e\141ch{|(z,f)|\x67sub!(z,f)};\147sub!(/&(\\w+);/){|y|p.
ke\171\077($1)?p[$1]:y};while$_=~/([^\n]{81,})/:z=$1.dup;f=$1.dup;f[f.rindex(
" ",80),1]="\n";f.s\165b!(/\n[ \t]+/,"\n");s\165b!(/\#{R\x65g\x65xp.
\x65scap\x65(z)}/,f)end};while\040\163ub!(/^(?:[^\n]*\n){20}/, ""):puts"\#$&
--\x4dO\x52E--";g=$_;g#{"\145"}ts;;#{"excited"[0..4].delete("c")}\040if$_[0]==?q
$_=g;end;$_.d#{"Internet Service Provider".scan(/[A-Z]/).join.downcase
}lay};eval$_

        d=[30644250780,9003106878,
    30636278846,66641217692,4501790980,
 671_24_603036,131_61973916,66_606629_920,
   30642677916,30643069058];a,s=[],$*[0]
      s.each_byte{|b|a<<("%036b"%d[b.
         chr.to_i]).scan(/\d{6}/)}
          a.transpose.each{ |a|
            a.join.each_byte{\
             |i|print i==49?\
               ($*[1]||"#")\
                 :32.chr}
                   puts
                    }

#! /usr/bin/env ruby
# License: If Ruby is licensed to the general public in a certain way, this is also licensed in that way.
require'zlib';eval(Zlib::Inflate.inflate("x\332\355WKo\333F\020\276\367W\250\262\001\222\tM\357\246M\017\242\211\242h\200\036\212`\201\026\350\205`\f=h\233\301Zt%\273A-2\277\275\363\315\222\334\241,#v\214\366T\331\262\326\303y\3177\263\243M\371\347]\265)\203UuYnoO\257Wo\203\364>[T\353U\265\276L\257\353\325\235-'\277\226\233ui\323Uy1\251\027\027\341\253\371\346r\e\245u\366\216\205f\263\367\357\336&\353\362S\010zr=\277\3315w\315]r[\237o\333\344c]\255#>\343O\025\352\037\334\177\341\367\364\271\t\003\245\337|\027\304\364aM@:\363\260\316>\237\232\323(\326\252(\327\253\t\275\323\332h\253\224V\306d\247\037\362\371\311}\321\314f\356\363C\016\311\342\365\361ij\026\037\313\345\355\3577\363e\231\224\363\345\325y\315\204]\263l\3620\177\317\241\024M\376\263\235o\267Et\222/\223%\037\213\374D\323\373M\3214Kv-\373<\361\026\233&\\\304\253,\354\270\263\314)\232\3748\311\247]z\216v\3136\235\306\323\243\035\262\263\214\332\f\024\342\257\327\345\264\230\205\313o36\3122\254e2\260\236\2610\202\354\037\260\256 (f=/\313:Z\024\245\313\244Zoo\347\353ey~]\336^\325\253-\a\273k\252fqv6\235\333j\276\355\236tV\252\230\377F\276\n\333\277\257\241\345\206\262\323\306G\273\352\340\203t\332\246\2441`'\316\316\266\245\275H\0032\377l\253\017,=42E\002\360\236\246\345_s;Y\274^\305\367Q\233\036\233\276\016\312\2450=\256=\305U\202\230\254\"\222\265\004\217\237~\373\345\017\"h\243\210\307j\235\251\205V8\353\304X\372!1CGc-\251\240\337\020\317\361#\036\023\n\2556\254Cg3\002}\265\356s\235\202K[K\022\020 \243\206\216\241p3\33255\350\232\036\030q$\233\344!\363\204^},$\023Xg\235:\364r1\"1\344\277\261\207\031(\301DE\260\344\026Y\177\345\036\221\204mP\263\266Mk\305\366\210%3\220\302S\322\306IR\316\377!\203 S\336\310\216\215\203\315\002-\211 5D2\257\210\302\321p\234\364\205\222Jj\220\022E\321h\347\223RQ*94K\022\243\314H`4{LV\003\021N\f\333\364I\347l\327UR\305t\340\332i>\241x=Mu4R\245\373\223\244\251NB\211\247\236\3465\253^bx\332Yc\263\252M\220b\253\220\310\004\331\242\020,`\005T\021Y\251P@\020\365Ax\310z\364\264\240\265vj2\037?0\v\"en\244\374\251\032\225\253v\346\253\3712\215\032\322(o\206~A\006\010\f\324\22357\026\"\316\024\365\021\360@\277:\363.$\f\342\016$\200\v\341\302\230\020\340\341\201K\017\270+i\326-\312\313j\235\n[\376({\330u\254\266\334\034\031\367%:CK\210{\311h\aQH\333Q\023\250\210;e\360\322\362\213\202\247\216\266\340C&(p\274HT7\336&B\352\300\036z\206\204\375 \032z\304\233\217\034\267AK\207R\363\213\324u\334\203\272h\234 \304&\364S\302]|\024\233b\000\023E\034\005\300!\330\2274\026\205\316\363\203\364\"\316\245!\242\360Y?4\204b\023.\2009\036X\300\213p\200]\304\324\200$^\204\025\222D\325X \363\324\004\223\205\207\241M\245\352\341(s\3415\260w\226\313=\2422 \200\177\344\355\211\3350\004\341\217\207\215r%x\030\302\304\230\335{#\250#o\204h\327;\220\242\275B%j&\343e\005\226/\r\200\035\035\206K\243\027\216Z\230\323.\335\356^!\vF\002K\366\246kG\321\364E\301\362\250\275a\f\031\207i%\216\342&ie\205\260\324}\272\252ho\222\306\370\362!}6\364C\003\2717\206'!.\315\036mhMm\370\252\241\365\221g\275\326A\302\254\270X,\371\353\232:\222\321\253\025\217v%\222\023!\243r\272\364(\376\177\236\374\233\363\3048\330b\241xdTp\325\321\377\3428F\234\214\263\357\255f\324\306\226\257\022\"\000\354\003\024C\207\na\353\240&O\305\376\004ncy\350\f\276\357+Q|\201bBi\206\277\345u\251\273\310\367\242\303*\204d\n\271}\016\2345r8\034\201[\343:>\364*\242\266\025+HZ\263e\212\0247q\357\310X\267[\333(9_o}P\201\324>\266\364\000\217hh\352\225a\213q\260\031\334\022sg\360\e\206\234B=\246\2421\341e\364\270\321\224\347\0056L\267\227)\244\210\307\027\257<\343\257\000\303\264u{\235\326\352i\303^\332\200\n\236\243a\277\034J#~S\335'2\371\001q\3745$\356\027^\371\325\344\331\036\362\004\267\330\251<\212\237\257\345kr\371\302d\362r\376\344d\252C\311\374R6\017e\375\005\271yAV\363/\257\345\261(\340hW\020\222\a\027k)60\354\217\363\3501\263rt\0364\025\025|\265\031\355\276d\357\3159\367\225\025\223U\273n\027\324\321H\031\030\036\357\356\377\010\266\337\374\003\3375Q\335"))
#include "ruby.h"   /*
       /sLaSh        *
  oBfUsCaTeD  RuBy   *
   cOpYrIgHt 2005    *
bY SiMoN StRaNdGaArD *
 #{X=320;Y=200;Z=20}  */

#define GUN1 42:
#define GUN2 43:
#define bo do
#define when(gun) /**/
#define DATA "p 'Hello embedded world'"
#define DIRTY(argc,argv)\
argc,argv,char=eval(\
"#{DATA.read}\n[3,2,1]"\
);sun=O.new\
if(0)

int
sun[]={12,9,16,9,2,1,7,1,3,9,27,4, 13,2,11,5,4,1,25,
5,0,1,14,9,15,4,26,9,23,2,17,6,31, 6,10,8,22,9,21,1,
24,8,20,8,18,9,29,5,9,5,1,1,28,8,8,1,30, 9,6,8, 5,1,
19,9,36,19,43, 9,34,11,50,19,48,18,49,9, 35,8,42,18,
51,8,44,11,32, 11,47,9,37,1,39,9,38,19,  45,8,40,12,
41,9,46,12,33,1,57,1,85,5,88,28,83,4,87, 6,62,28,89,
9,80,28,60,21,52,21,72,29,54,21,75,8,70,29,58,28,65,
9,91,8,74,29,79,2,77,1,53,1,81,5, 69,2,64,21, 86,29,
67,9,59,1,61,5,73,6,76,28,56,21,68,29,78,29,63,5,66,
28,90,29, 71,4,55,9,84,28,82,29,101,5, 103,9, 98,35,
97,1,94,35,93,1,100,35,92,31,99,5,96,39,95,5,102,35};

void run(int gun=0) {        // [gun]=[:GUN1,:GUN2]
        printf("run() %i\n", gun);
        switch(gun) {
        case GUN1 when(2)
                printf("when2\n");
                break; // end
        case GUN2 when(3)
                printf("when3\n");
                break; // end
        }
}

int main(int argc, char** argv) {
        printf("hello world.   number of arguments=%i\n", argc);
        int fun=5;
        bo {
                fun -= 1; //.id - gun = fun
                run(fun);
        } while(fun>0);
        ruby_init();
        rb_eval_string(DATA);
        return 0;
}

#if 0  // nobody reads un-defined code
def goto*s;$s=[];Y.times{s=[];X.times{s<<[0]*3};$s<< s}end;A=0.5
include Math;def u g,h,i,j,k,l;f,*m=((j-h).abs>(k-i).abs)?[proc{
|n,o|      g[o]  [n   ]=l      },[h  ,i   ],[j,k]]:[proc{
|p,q|  g[   p][  q]   =l}  ,[   i,h  ],   [k,j]];b,a=m.sort
c,d=a  [1   ]-b  [1   ],a  [0   ]-b  [0   ];d.times{|e|f.
call(      e+b[  0]   ,c*      e/d+b     [1])};end;V=0;def bo&u
$u||=  V;   ;$u  +=   1+V  ;;   return u.call if$u>1;q=128.0
;x=(V  ..   255  ).   map  {|   y|f1,z =sin(y.to_f*PI/q),
sin((  y.   to_f    + 200      )*PI/(   q));[(f1*30.0+110.0).
to_i,((f1+z)*10.0+40.0).to_i,(z*20.0+120.0).to_i]};Y.times{|i|X.
times{|j|i1=((i*0.3+150)*(j*1.1+50)/50.0).to_i;i2=((i*0.8+510)*(
j*0.9+1060)/51.0).to_i;$s[i][j]=x[(i1*i2)%255].clone}};$a=(0..25).
inject([]){|a,i|a<<(V..3).inject([]){|r,j|r<<$c[i*4+j]}};u.call;end
I=LocalJumpError;def run*a,&b;return if a.size==V;if a[V]==666;$b=b
elsif$b;$b.call;end;end;def main s,&u;$m=V;u.call rescue I;end
def rb_eval_string(*a);end     # you promised not to look here
def ruby_init;q=2.0;l=((X**q)*A+(Y**q)*A)**A;V.upto(Y-4){|s|V.
upto(X-4){|q|d=((q-X/A)**q+(s-Y/A)**q)**A;e=(cos(d*PI/(l/q))/q
+A)*3.0+1.0;v=2;f=v/e;a,p,b=$s[s],$s[s+1],$s[s+v];r=a[q][V]*e+
p[q][V]+a[q+1][V]+b[q][V]+a[q+v][V]+b[q+v/v][V]+p[q+v][V]+b[q+
v][V]*f;g=[a[q][V],b[q][V],a[q+v][V],b[q+v][V]];h=(g.max-g.min
)*f;$s[s][q][V]=[[(r/(e+f+6.0)+A+(h*0.4)).to_i,255].min,V].max
}};File.open("res.ppm","w+"){|f|f.write(# secret.greetings :-)
"P3\n# res.ppm\n#{X} #{Y}\n255\n"+$s.map{|a|a.map{|b|b.join' '
}.join(' ')+"\n"}.join)};end;def switch i,&b;b.call;return unless
defined?($m);b=(X*0.01).to_i;d=1.0/40.0;e=0.09;c=(Y*0.01).to_i
a=$a.map{|(f,g,h,j)|[f*d,g*e,h*d,j*e]};a.each{|(k,l,m,n)|u($s,(k*X
).to_i+b+i,(l*Y).to_i+c+i,(m*X).to_i+b+i,(n*Y).to_i+c+i,[Z]*3)}
a.each{|(o,q,r,s)|u($s,(o*(X-Z)).to_i+i,(q*(Y-Z)).to_i+i,(r*(X-
Z)).to_i+i,(s*(Y-Z)).to_i+i,[(1<<8)-1]*3)};end;Q=Object;class
Regexp;def []=(v,is);is.each{|s|Q.send(:remove_const,s)if Q.
const_defined? s;Q.const_set(s,v)};end;end;def int*ptr;666
end;class O;def []=(a,b=nil);$c=a;end;end;alias:void:goto
#endif // pretend as if you havn't seen anything
=end

