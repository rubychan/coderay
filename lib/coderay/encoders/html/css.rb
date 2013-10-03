module CodeRay
module Encoders

  class HTML
    class CSS  # :nodoc:
      def initialize style_name = :default
        @style_name = style_name
      end

      def style
        @style ||= CodeRay::Styles[@style_name]
      end

      def stylesheet
        @css ||= [
          style::CSS_MAIN_STYLES,
          style::TOKEN_COLORS.gsub(/^(?!$)/, '.CodeRay ')
        ].join("\n")
      end

      def get_style_for_css_classes css_classes
        cl = styles[css_classes.first]
        return '' unless cl
        style = ''
        1.upto css_classes.size do |offset|
          break if style = cl[css_classes[offset .. -1]]
        end
        # warn 'Style not found: %p' % [styles] if style.empty?
        return style
      end

      private

      CSS_CLASS_PATTERN = /
        (                    # $1 = selectors
          (?:
            (?: \s* \. [-\w]+ )+
            \s* ,?
          )+
        )
        \s* \{ \s*
        ( [^\}]+ )?          # $2 = style
        \s* \} \s*
      |
        ( [^\n]+ )           # $3 = error
      /mx
      def styles
        @styles ||= Hash.new.tap do |styles|
          style::TOKEN_COLORS.scan CSS_CLASS_PATTERN do |selectors, style, error|
            raise "CSS parse error: '#{error.inspect}' not recognized" if error
            for selector in selectors.split(',')
              classes = selector.scan(/[-\w]+/)
              cl = classes.pop
              styles[cl] ||= Hash.new
              styles[cl][classes] = style.to_s.strip.delete(' ').chomp(';')
            end
          end
        end
      end

    end
  end

end
end
