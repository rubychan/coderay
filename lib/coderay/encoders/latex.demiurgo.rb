module CodeRay
module Encoders

  # = LaTeX Encoder
  #
  # Encoder producing LaTeX.
  class Latex < Encoder

    include Streamable
    register_for :latex

    FILE_EXTENSION = 'tex'

    DEFAULT_OPTIONS = {
      :wrap => true,
    }

  protected
    def text_token text, kind
      @out <<
        if kind == :space
          text
        else
          text = escape_latex(text)
          "\\syn#{kind_to_command(kind)}{#{text}}"
        end
    end

    def block_token action, kind
      @out << super
    end

    def open_token kind
      "\\syn#{kind_to_command(kind)}{"
    end

    def close_token kind
      "}"
    end

    def kind_to_command kind
      kind.to_s.gsub(/[^a-z0-9]/i, '').to_sym
    end

    def finish options
      case options[:wrap]
      when true, 1, :semiverbatim
        @out = "\\begin{semiverbatim}\n#{@out}\n\\end{semiverbatim}\n"
      when false, 0
        # Nothing to do
      else
        raise ArgumentError, "Unknown :wrap option: '#{options[:wrap]}'"
      end

      super
    end

    # Escape text so it's interpreted literally by LaTeX compilers
    def escape_latex string
      string.to_s.gsub(/[$\\{}_%#&~^"]/) do |s|
        case s
        when '$'
          '\$'
        when '\\'
          '\synbs{}'
        when /[{}_%#&]/
          "\\#{s}"
        when /[~^]/
          "\\#{s}{}"
        when '"'
          '"{}'
        end
      end
    end

  end

end
end
