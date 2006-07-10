module CodeRay
module Scanners

  class Plaintext < Scanner

    register_for :plaintext, :plain

    def scan_tokens tokens, options
      tokens << [scan_until(/\z/), :plain]
    end

  end

end
end
