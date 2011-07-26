module CodeRay
module Scanners
  
  map \
    :'c++'       => :cpp,
    :cplusplus   => :cpp,
    :ecmascript  => :java_script,
    :ecma_script => :java_script,
    :erb         => :rhtml,
    :irb         => :ruby,
    :javascript  => :java_script,
    :js          => :java_script,
    :nitro       => :nitro_xhtml,
    :pascal      => :delphi,
    :patch       => :diff,
    :plain       => :text,
    :plaintext   => :text,
    :xhtml       => :html,
    :yml         => :yaml
  
  default :text
  
end
end
