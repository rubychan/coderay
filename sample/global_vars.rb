code = <<'CODE'
$ie.text_field(:name, "pAnfrage ohne $gV und mit #{$gv}").set artikel
oder
text = $bla.test(...) 
CODE

require 'coderay'

tokens = CodeRay.scan code, :ruby
tokens.each_text_token { |text, kind| text.upcase! }
tokens.each(:global_variable) { |text, kind| text.replace '<--%s-->' % text }

print tokens
