module CodeRay
module Scanners

  # A scanner for LTSV.
  # http://ltsv.org
  class Ltsv < Scanner

    register_for :ltsv
    file_extension 'ltsv'

  protected

    def scan_tokens encoder, options

      state = :initial

      until eos?

        if match = scan(/(?:\r?\n)+/)
          encoder.text_token match, :space
          state = :initial if match.index(/\r?\n/)

        elsif (state == :initial || state == :tab) && match = scan(/[^:]+/)
          encoder.text_token match, :key
          state = :label

        elsif state == :label && match = scan(/:/)
          encoder.text_token match, :delimiter
          state = :colon

        elsif state == :colon && match = scan(/[^\t\r\n]*/)
          encoder.text_token match, :value
          state = :value

        elsif state == :value && match = scan(/\t/)
          encoder.text_token match, :space
          state = :tab

        else
          raise
        end
      end

      encoder
    end
  end

end
end
