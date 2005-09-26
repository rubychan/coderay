module CodeRay

  # This module holds the Encoder class and its subclasses.
  # For example, the HTML encoder is named CodeRay::Encoders::HTML
  # can be found in coderay/encoders/html.
  # 
  # Encoders also provides methods and constants for the register mechanism
  # and the [] method that returns the Encoder class belonging to the
  # given format.
  module Encoders

    # Raised if Encoders[] fails because:
    # * a file could not be found
    # * the requested Encoder is not registered
    EncoderNotFound = Class.new Exception

    def Encoders.create_encoders_hash
      Hash.new do |h, lang|
        path = Encoders.path_to lang
        lang = lang.to_sym
        begin
          require path
        rescue LoadError
          raise EncoderNotFound, "#{path} not found."
        else
          # Encoder should have registered by now
          unless h[lang]
            raise EncoderNotFound, "No Encoder for #{lang} found in #{path}."
          end
        end
        h[lang]
      end
    end

    # Loaded Encoders are saved here.
    ENCODERS = create_encoders_hash

    class << self

      # Every Encoder class must register itself for one or more +formats+
      # by calling register_for, which calls this method.
      #
      # See CodeRay::Encoder.register_for.
      def register encoder_class, *formats
        for format in formats
          ENCODERS[format.to_sym] = encoder_class
        end
      end

      # Returns the Encoder for +lang+.
      # 
      # Example:
      #  require 'coderay'
      #  yaml_encoder = CodeRay::Encoders[:yaml]
      def [] lang
        ENCODERS[lang]
      end

      # Alias for +[]+.
      alias load []

      # Returns the path to the encoder for format.
      def path_to plugin
        File.join 'coderay', 'encoders', "#{plugin}.rb"
      end

    end


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

      attr_reader :token_stream

      class << self
        
        # Register this class for the given langs.
        #
        # Example:
        #   class MyEncoder < CodeRay::Encoders:Encoder
        #     register_for :myenc
        #     ...
        #   end
        #
        # See Encoder.register.
        def register_for *args
          Encoders.register self, *args
        end

        # Returns if the Encoder can be used in streaming mode.
        def streamable?
          is_a? Streamable
        end
        
        # If FILE_EXTENSION isn't defined, this method returns the downcase
        # class name instead.
        def const_missing sym
          if sym == :FILE_EXTENSION
            sym.to_s.downcase
          else
            super
          end
        end
        
      end

      # Subclasses are to store their default options in this constant.
      DEFAULT_OPTIONS = { :stream => false }

      # The options you gave the Encoder at creating.
      attr_accessor :options

      # Creates a new Encoder.
      # +options+ is saved and used for all encode operations, as long as you
      # don't overwrite it there by passing additional options.
      # 
      # Encoder objects provide three encode methods:
      # - encode simply takes a +code+ string and a +lang+
      # - encode_tokens expects a +tokens+ object instead
      # - encode_stream is like encode, but uses streaming mode.
      # 
      # Each method has an optional +options+ parameter. These are added to
      # the options you passed at creation.
      def initialize options = {}
        @options = self.class::DEFAULT_OPTIONS.merge options
        raise "I am only the basic Encoder class. I can't encode anything. :(\n" + 
          "Use my subclasses." if self.class == Encoder
      end

      # Encode a Tokens object.
      def encode_tokens tokens, options = {}
        options = @options.merge options
        setup options
        compile tokens, options
        finish options
      end

      # Encode the given +code+ after tokenizing it using the Scanner for
      # +lang+.
      def encode code, lang, options = {}
        options = @options.merge options
        scanner_options = options.fetch(:scanner_options, {})
        tokens = CodeRay.scan code, lang, scanner_options
        encode_tokens tokens, options
      end

      # You can use highlight instead of encode, if that seems
      # more clear to you.
      alias highlight encode

      # Encode the given +code+ using the Scanner for +lang+ in streaming
      # mode.
      def encode_stream code, lang, options = {}
        raise NotStreamableError, self unless kind_of? Streamable
        options = @options.merge options
        setup options
        scanner_options = options.fetch :scanner_options, {}
        @token_stream = CodeRay.scan_stream code, lang, scanner_options, &self
        finish options
      end

      # Behave like a proc. The tokens method is converted to a proc.
      def to_proc
        method(:token).to_proc
      end

    protected
    
      # Called with merged options before encoding starts.
      # Sets @out to an empty string.
      # 
      # See the HTML Encoder for an example of option caching.
      def setup options
        @out = ''
      end

      # Called with +text+ and +kind+ of the currently scanned token.
      # For simple scanners, it's enougth to implement this method.
      #
      # Raises a NotImplementedError exception if it is not overwritten in
      # subclass.
      def token text, kind
        raise NotImplementedError, "#{self.class}#token not implemented."
      end

      # Called with merged options after encoding starts.
      # The return value is the result of encoding, typically @out.
      def finish options 
        @out
      end

      # Do the encoding.
      #
      # The already created +tokens+ object must be used; it can be a
      # TokenStream or a Tokens object.
      def compile tokens, options
        tokens.each(&self)
      end

    end	

  end
end

# vim:sw=2:ts=2:et:tw=78
