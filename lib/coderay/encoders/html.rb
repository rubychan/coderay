require 'set'

module CodeRay
module Encoders

  # = HTML Encoder
  #
  # This is CodeRay's most important highlighter:
  # It provides save, fast XHTML generation and CSS support.
  #
  # == Usage
  #
  #  require 'coderay'
  #  puts CodeRay.scan('Some /code/', :ruby).html  #-> a HTML page
  #  puts CodeRay.scan('Some /code/', :ruby).html(:wrap => :span)
  #  #-> <span class="CodeRay"><span class="co">Some</span> /code/</span>
  #  puts CodeRay.scan('Some /code/', :ruby).span  #-> the same
  #  
  #  puts CodeRay.scan('Some code', :ruby).html(
  #    :wrap => nil,
  #    :line_numbers => :inline,
  #    :css => :style
  #  )
  #  #-> <span class="no">1</span>  <span style="color:#036; font-weight:bold;">Some</span> code
  #
  # == Options
  #
  # === :tab_width
  # Convert \t characters to +n+ spaces (a number.)
  # 
  # Default: 8
  #
  # === :css
  # How to include the styles; can be :class or :style.
  #
  # Default: :class
  #
  # === :wrap
  # Wrap in :page, :div, :span or nil.
  #
  # You can also use Encoders::Div and Encoders::Span.
  #
  # Default: nil
  #
  # === :title
  # 
  # The title of the HTML page (works only when :wrap is set to :page.)
  #
  # Default: 'CodeRay output'
  #
  # === :line_numbers
  # Include line numbers in :table, :inline, or nil (no line numbers)
  #
  # Default: nil
  #
  # === :line_number_anchors
  # Adds anchors and links to the line numbers. Can be false (off), true (on),
  # or a prefix string that will be prepended to the anchor name.
  #
  # The prefix must consist only of letters, digits, and underscores.
  #
  # Default: true, default prefix name: "line"
  #
  # === :line_number_start
  # Where to start with line number counting.
  #
  # Default: 1
  #
  # === :bold_every
  # Make every +n+-th number appear bold.
  #
  # Default: 10
  #
  # === :highlight_lines
  # 
  # Highlights certain line numbers.
  # Can be any Enumerable, typically just an Array or Range, of numbers.
  # 
  # Bolding is deactivated when :highlight_lines is set. It only makes sense
  # in combination with :line_numbers.
  #
  # Default: nil
  #
  # === :hint
  # Include some information into the output using the title attribute.
  # Can be :info (show token kind on mouse-over), :info_long (with full path)
  # or :debug (via inspect).
  #
  # Default: false
  class HTML < Encoder

    register_for :html

    FILE_EXTENSION = 'html'

    DEFAULT_OPTIONS = {
      :tab_width => 8,

      :css => :class,

      :style => :alpha,
      :wrap => nil,
      :title => 'CodeRay output',

      :line_numbers => nil,
      :line_number_anchors => 'n',
      :line_number_start => 1,
      :bold_every => 10,
      :highlight_lines => nil,

      :hint => false,
    }

    helper :output, :numbering, :css

    attr_reader :css

  protected

    HTML_ESCAPE = {  #:nodoc:
      '&' => '&amp;',
      '"' => '&quot;',
      '>' => '&gt;',
      '<' => '&lt;',
    }

    # This was to prevent illegal HTML.
    # Strange chars should still be avoided in codes.
    evil_chars = Array(0x00...0x20) - [?\n, ?\t, ?\s]
    evil_chars.each { |i| HTML_ESCAPE[i.chr] = ' ' }
    #ansi_chars = Array(0x7f..0xff)
    #ansi_chars.each { |i| HTML_ESCAPE[i.chr] = '&#%d;' % i }
    # \x9 (\t) and \xA (\n) not included
    #HTML_ESCAPE_PATTERN = /[\t&"><\0-\x8\xB-\x1f\x7f-\xff]/
    HTML_ESCAPE_PATTERN = /[\t"&><\0-\x8\xB-\x1f]/

    TOKEN_KIND_TO_INFO = Hash.new do |h, kind|
      h[kind] =
        case kind
        when :pre_constant
          'Predefined constant'
        else
          kind.to_s.gsub(/_/, ' ').gsub(/\b\w/) { $&.capitalize }
        end
    end

    TRANSPARENT_TOKEN_KINDS = [
      :delimiter, :modifier, :content, :escape, :inline_delimiter,
    ].to_set

    # Generate a hint about the given +kinds+ in a +hint+ style.
    #
    # +hint+ may be :info, :info_long or :debug.
    def self.token_path_to_hint hint, kinds
      # FIXME: TRANSPARENT_TOKEN_KINDS?
      # if TRANSPARENT_TOKEN_KINDS.include? kinds.first
      #   kinds = kinds[1..-1]
      # else
      #   kinds = kinds[1..-1] + kinds.first
      # end
      title =
        case hint
        when :info
          TOKEN_KIND_TO_INFO[kinds.first]
        when :info_long
          kinds.map { |kind| TOKEN_KIND_TO_INFO[kind] }.join('/')
        when :debug
          kinds.inspect
        end
      title ? " title=\"#{title}\"" : ''
    end

    def setup options
      super
      
      @HTML_ESCAPE = HTML_ESCAPE.dup
      @HTML_ESCAPE["\t"] = ' ' * options[:tab_width]
      
      @opened = [nil]
      @css = CSS.new options[:style]
      
      hint = options[:hint]
      if hint and not [:debug, :info, :info_long].include? hint
        raise ArgumentError, "Unknown value %p for :hint; \
          expected :info, :debug, false, or nil." % hint
      end

      case options[:css]

      when :class
        @css_style = Hash.new do |h, k|
          c = Tokens::AbbreviationForKind[k.first]
          h[k.dup] = 
            if c != :NO_HIGHLIGHT or (hint && k.first != :space)
              if hint
                title = HTML.token_path_to_hint hint, k
              end
              if c == :NO_HIGHLIGHT
                '<span%s>' % [title]
              else
                '<span%s class="%s">' % [title, c]
              end
            end
        end

      when :style
        @css_style = Hash.new do |h, k|
          classes = k.map { |c| Tokens::AbbreviationForKind[c] }
          h[k.dup] =
            if classes.first != :NO_HIGHLIGHT or (hint && k.first != :space)
              if hint
                title = HTML.token_path_to_hint hint, k
              end
              style = @css[*classes]
              if style
                '<span%s style="%s">' % [title, style]
              end
            end
        end

      else
        raise ArgumentError, "Unknown value %p for :css." % options[:css]

      end
    end

    def finish options
      not_needed = @opened.shift
      unless @opened.empty?
        warn '%d tokens still open: %p' % [@opened.size, @opened]
        @out << '</span>' * @opened.size
      end
      
      @out.extend Output
      @out.css = @css
      @out.number! options[:line_numbers], options
      @out.wrap! options[:wrap]
      @out.apply_title! options[:title]
      
      super
    end
    
  public
    
    def text_token text, kind
      if text =~ /#{HTML_ESCAPE_PATTERN}/o
        text = text.gsub(/#{HTML_ESCAPE_PATTERN}/o) { |m| @HTML_ESCAPE[m] }
      end
      @opened[0] = kind
      @out <<
        if style = @css_style[@opened]
          style + text + '</span>'
        else
          text
        end
    end
    
    # token groups, eg. strings
    def begin_group kind
      @opened[0] = kind
      @opened << kind
      @out << (@css_style[@opened] || '<span>')
    end
    
    def end_group kind
      if $CODERAY_DEBUG and (@opened.size == 1 or @opened.last != kind)
        warn 'Malformed token stream: Trying to close a token (%p) ' \
          'that is not open. Open are: %p.' % [kind, @opened[1..-1]]
      end
      @out << 
        if @opened.empty?
          '' # nothing to close
        else
          @opened.pop
          '</span>'
        end
    end
    
    # whole lines to be highlighted, eg. a deleted line in a diff
    def begin_line kind
      @opened[0] = kind
      style = @css_style[@opened]
      @opened << kind
      @out <<
        if style
          style.sub '<span', '<div'
        else
          '<div>'
        end
    end
    
    def end_line kind
      if $CODERAY_DEBUG and (@opened.size == 1 or @opened.last != kind)
        warn 'Malformed token stream: Trying to close a line (%p) ' \
          'that is not open. Open are: %p.' % [kind, @opened[1..-1]]
      end
      @out <<
        if @opened.empty?
          ''  # nothing to close
        else
          @opened.pop
          '</div>'
        end
    end

  end

end
end
