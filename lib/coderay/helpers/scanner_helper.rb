module CodeRay
module Scanners

  class Scanner

    # A WordList is a Hash with some additional features.
    # It is intended to be used for keyword recognition.
    class WordList < Hash

      def initialize default = false, case_mode = :case_match
        @case_ignore =
          case case_mode
          when :case_match then false
          when :case_ignore then true
          else
            raise ArgumentError,
              "#{self.class.name}.new: second argument must be :case_ignore or :case_match, but #{case_mode} was given."
          end

        if @case_ignore
          super() do |h, k|
            h[k] = h.fetch k.downcase, default
          end
        else
          super default
        end
      end

      def include? word
        self[word] if @case_ignore
        has_key? word
      end

      def add words, kind = true
        words.each do |word|
          self[mind_case(word)] = kind
        end
        self
      end

      alias words keys

      def case_ignore?
        @case_mode
      end

    private
      def mind_case word
        if @case_ignore
          word.downcase
        else
          word.dup
        end
      end

    end		

  end

end
end

# vim:sw=2:ts=2:et:tw=78
