code = <<'CODE'
$ie.text_field(:name, "pAnfrage ohne $gV und mit #{$gv}").set artikel
oder
text = $bla.test(...) 
CODE

require 'coderay'
require 'erb'
include ERB::Util

tokens = CodeRay.scan code, :ruby
tokens.each_text_token { |text, kind| text.replace h(text) }
tokens.each(:global_variable) { |text, kind| text.replace '<span class="glob-var">%s</span>' % text }

puts tokens.text
