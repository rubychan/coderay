module CodeRay
module Scanners

  map \
    :cpp => :c,
    :ecma => :java_script,
    :ecmascript => :java_script,
    :ecma_script => :java_script,
    :irb => :ruby,
    :javascript => :java_script,
    :js => :java_script,
    :nitro => :nitro_xhtml,
    :pascal => :delphi,
    :plain => :plaintext,
    :xhtml => :html,
    :yml => :yaml

  default :plain

end
end
