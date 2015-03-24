module CodeRay
module Scanners
  
  map \
    :'c++'       => :cpp,
    :cplusplus   => :cpp,
    :ecmascript  => :java_script,
    :ecma_script => :java_script,
    :rhtml       => :erb,
    :eruby       => :erb,
    :irb         => :ruby,
    :javascript  => :java_script,
    :javascript1 => :java_script1,
    :javascript2 => :java_script2,
    :javascript3 => :java_script3,
    :javascript4 => :java_script4,
    :javascript5 => :java_script5,
    :js          => :java_script,
    :pascal      => :delphi,
    :patch       => :diff,
    :plain       => :text,
    :plaintext   => :text,
    :xhtml       => :html,
    :yml         => :yaml
  
  default :text
  
end
end
