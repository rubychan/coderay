module CodeRay
module Scanners

  map :cpp => :c,
    :plain => :plaintext,
    :pascal => :delphi,
    :irb => :ruby,
    :xml => :html,
    :xhtml => :nitro_html

  default :plain

end
end
