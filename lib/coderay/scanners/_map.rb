module CodeRay
module Scanners
  
  map \
    :cplusplus => :cpp,
    :'c++' => :cpp,
    :ecmascript => :java_script,
    :ecma_script => :java_script,
    :irb => :ruby,
    :javascript => :java_script,
    :js => :java_script,
    :nitro => :nitro_xhtml,
    :pascal => :delphi,
    :patch => :diff,
    :plain => :plaintext,
    :xhtml => :html,
    :yml => :yaml
  
  default :plain
  
end
end
