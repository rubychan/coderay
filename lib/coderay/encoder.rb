module CodeRay

  # This module holds the Encoder class and its subclasses.
  # For example, the HTML encoder is named CodeRay::Encoders::HTML
  # can be found in coderay/encoders/html.
  #
  # Encoders also provides methods and constants for the register
  # mechanism and the [] method that returns the Encoder class
  # belonging to the given format.
  module Encoders
    extend PluginHost
    plugin_path File.dirname(__FILE__), 'encoders'

    # = Encoder
    #
    # The Encoder base class. Together with Scanner and
    # Tokens, it forms the highlighting triad.
    #
    # Encoder instances take a Tokens object and do something with it.
    #
    # The most common Encoder is surely the HTML encoder
    # (CodeRay::Encoders::HTML). It highlights the code in a colorful
    # html page.
    # If you want the highlighted code in a div or a span instead,
    # use its subclasses Div and Span.
    class Encoder
      extend Plugin
      plugin_host Encoders

      class << self

        # If FILE_EXTENSION isn't defined, this method returns the
        # downcase class name instead.
        def const_missing sym
          if sym == :FILE_EXTENSION
            plugin_id
          else
            super
          end
        end

      end

      # Subclasses are to store their default options in this constant.
      DEFAULT_OPTIONS = { }

      # The options you gave the Encoder at creating.
      attr_accessor :options

      # Creates a new Encoder.
      # +options+ is saved and used for all encode operations, as long
      # as you don't overwrite it there by passing additional options.
      #
      # Encoder objects provide three encode methods:
      # - encode simply takes a +code+ string and a +lang+
      # - encode_tokens expects a +tokens+ object instead
      #
      # Each method has an optional +options+ parameter. These are
      # added to the options you passed at creation.
      def initialize options = {}
        @options = self.class::DEFAULT_OPTIONS.merge options
        raise "I am only the basic Encoder class. I can't encode "\
          "anything. :( Use my subclasses." if self.class == Encoder
        $ALREADY_WARNED_OLD_INTERFACE = false
      end

      # Encode a Tokens object.
      def encode_tokens tokens, options = {}
        options = @options.merge options
        setup options
        compile tokens, options
        finish options
      end

      # Encode the given +code+ using the Scanner for +lang+.
      def encode code, lang, options = {}
        options = @options.merge options
        setup options
        scanner_options = CodeRay.get_scanner_options options
        scanner_options[:tokens] = self
        CodeRay.scan code, lang, scanner_options
        finish options
      end

      # You can use highlight instead of encode, if that seems
      # more clear to you.
      alias highlight encode

      # Return the default file extension for outputs of this encoder.
      def file_extension
        self.class::FILE_EXTENSION
      end
      
      def << token
        warn 'Using old Tokens#<< interface.' unless $ALREADY_WARNED_OLD_INTERFACE
        $ALREADY_WARNED_OLD_INTERFACE = true
        self.token(*token)
      end

    protected

      # Called with merged options before encoding starts.
      # Sets @out to an empty string.
      #
      # See the HTML Encoder for an example of option caching.
      def setup options
        @out = ''
      end
      
    public
      
      # Called with +content+ and +kind+ of the currently scanned token.
      # For simple scanners, it's enougth to implement this method.
      #
      # By default, it calls text_token, begin_group, end_group, begin_line,
      # or end_line, depending on the +content+.
      def token content, kind
        case content
        when String
          text_token content, kind
        when :begin_group
          begin_group kind
        when :end_group
          end_group kind
        when :begin_line
          begin_line kind
        when :end_line
          end_line kind
        else
          raise 'Unknown token content type: %p' % [content]
        end
      end
      
      # Called for each text token ([text, kind]), where text is a String.
      def text_token text, kind
      end
      
      # Starts a token group with the given +kind+.
      def begin_group kind
      end
      
      # Ends a token group with the given +kind+.
      def end_group kind
      end
      
      # Starts a new line token group with the given +kind+.
      def begin_line kind
      end
      
      # Ends a new line token group with the given +kind+.
      def end_line kind
      end
      
    protected
      
      # Called with merged options after encoding starts.
      # The return value is the result of encoding, typically @out.
      def finish options
        @out
      end
      
      # Do the encoding.
      #
      # The already created +tokens+ object must be used; it must be a
      # Tokens object.
      def compile tokens, options = {}
        content = nil
        for item in tokens
          if item.is_a? Array
            warn 'two-element array tokens are deprecated'
            content, item = *item
          end
          if content
            token content, item
            content = nil
          else
            content = item
          end
        end
        raise if content
      end
      
    end

  end
end
