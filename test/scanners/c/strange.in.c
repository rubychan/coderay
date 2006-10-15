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

# if   0  // nobody reads un-defined code
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
