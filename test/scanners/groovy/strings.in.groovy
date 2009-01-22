/* This is valid Groovy code. */

var = 1
def another(a,b,c,d) { }

// "\/"  Error?
"text $var $var.meth text ${if (1) {another("st", 'ri', /ng/, "}")}} \t text \n text \uafaf text \$novar text \'\"\\ "  //';

'text $novar text ${not_interpreted} \t text \n text \uafaf text \$novar text \'\"\\ ';

/text $var $var.meth text ${if (1) {another("st", 'ri', /ng/, "}")}} \t text \n text \uafaf text \$var \\$var text \'\"\\\/ /;

youcannotescape = 0;
println(/\$youcannotescape$var/)

// "\/"  Error?
~"text $var $var.meth text ${if (1) {another("st", 'ri', /ng/, "}")}} \t text \n text \uafaf text \$novar text \'\"\\ "  //';

~'text $novar text ${0} \t text \n text \uafaf text \$novar text \'\"\\ ';

~/text $var $var.meth text ${if (1) {another("st", 'ri', /ng/, "}")}} \t (text) \n text \uafaf text \$var \\$var text \'\"\\\/ /;

println(~/\$youcannotescape$var/)

println "Age $age: ${list.collect{it.'name'}.join(', ')}"

"""
text $var $var.meth text ${if (1) {another("st", 'ri', /ng/, "}")}} \t text \n text \uafaf text \$novar text \'\"\\ \"""
"""

'''
text $novar text ${not_interpreted} \t text \n text \uafaf text \$novar text \'\"\\ \'''
'''

