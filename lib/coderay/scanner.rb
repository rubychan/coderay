module CodeRay

  require 'coderay/helpers/plugin'

  # = Scanners
  #
  # This module holds the Scanner class and its subclasses.
  # For example, the Ruby scanner is named CodeRay::Scanners::Ruby
  # can be found in coderay/scanners/ruby.
  #
  # Scanner also provides methods and constants for the register
  # mechanism and the [] method that returns the Scanner class
  # belonging to the given lang.
  #
  # See PluginHost.
  module Scanners
    extend PluginHost
    plugin_path File.dirname(__FILE__), 'scanners'

    require 'strscan'

    # = Scanner
    #
    # The base class for all Scanners.
    #
    # It is a subclass of Ruby's great +StringScanner+, which
    # makes it easy to access the scanning methods inside.
    #
    # It is also +Enumerable+, so you can use it like an Array of
    # Tokens:
    #
    #   require 'coderay'
    #   
    #   c_scanner = CodeRay::Scanners[:c].new "if (*p == '{') nest++;"
    #   
    #   for text, kind in c_scanner
    #     puts text if kind == :operator
    #   end
    #   
    #   # prints: (*==)++;
    #
    # OK, this is a very simple example :)
    # You can also use +map+, +any?+, +find+ and even +sort_by+,
    # if you want.
    class Scanner < StringScanner
      
      extend Plugin
      plugin_host Scanners

      # Raised if a Scanner fails while scanning
      ScanError = Class.new(Exception)

      require 'coderay/helpers/word_list'

      # The default options for all scanner classes.
      #
      # Define @default_options for subclasses.
      DEFAULT_OPTIONS = { }
      
      KINDS_NOT_LOC = [:comment, :doctype, :docstring]

      class << self

        def normify code
          code = code.to_s.dup
          # try using UTF-8
          if code.respond_to? :force_encoding
            debug, $DEBUG = $DEBUG, false
            begin
              code.force_encoding 'UTF-8'
              code[/\z/]  # raises an ArgumentError when code contains a non-UTF-8 char
            rescue ArgumentError
              code.force_encoding 'binary'
            ensure
              $DEBUG = debug
            end
          end
          # convert the string to UNIX newline format
          code.gsub!(/\r\n?/, "\n") if code.index ?\r
          code
        end
        
        def file_extension extension = nil
          if extension
            @file_extension = extension.to_s
          else
            @file_extension ||= plugin_id.to_s
          end
        end

      end

=begin
## Excluded for speed reasons; protected seems to make methods slow.

  # Save the StringScanner methods from being called.
  # This would not be useful for highlighting.
  strscan_public_methods =
    StringScanner.instance_methods -
    StringScanner.ancestors[1].instance_methods
  protected(*strscan_public_methods)
=end

      # Create a new Scanner.
      #
      # * +code+ is the input String and is handled by the superclass
      #   StringScanner.
      # * +options+ is a Hash with Symbols as keys.
      #   It is merged with the default options of the class (you can
      #   overwrite default options here.)
      #
      # Else, a Tokens object is used.
      def initialize code='', options = {}
        raise "I am only the basic Scanner class. I can't scan "\
          "anything. :( Use my subclasses." if self.class == Scanner
        
        @options = self.class::DEFAULT_OPTIONS.merge options

        super Scanner.normify(code)

        @tokens = options[:tokens] || Tokens.new
        @tokens.scanner = self if @tokens.respond_to? :scanner=

        setup
      end
      
      # Sets back the scanner. Subclasses are to define the reset_instance
      # method.
      def reset
        super
        reset_instance
      end

      def string= code
        code = Scanner.normify(code)
        super code
        reset_instance
      end

      # More mnemonic accessor name for the input string.
      alias code string
      alias code= string=

      # Returns the Plugin ID for this scanner.
      def lang
        self.class.plugin_id.to_s
      end

      # Scans the code and returns all tokens in a Tokens object.
      def tokenize source = nil, options = {}
        options = @options.merge(options)
        @tokens = options[:tokens] || @tokens || Tokens.new
        @tokens.scanner = self if @tokens.respond_to? :scanner=
        case source
        when String
          self.string = source
        when Array
          self.string = source.join
        when nil
          reset
        else
          raise ArgumentError, 'expected String, Array, or nil'
        end
        scan_tokens @tokens, options
        @cached_tokens = @tokens
        if source.is_a? Array
          @tokens.split_into_parts(*source.map { |part| part.size })
        else
          @tokens
        end
      end
      
      # Caches the result of tokenize.
      def tokens
        @cached_tokens ||= tokenize
      end
      
      # Traverses the tokens.
      def each &block
        tokens.each(&block)
      end
      include Enumerable

      # The current line position of the scanner. See also #column.
      #
      # Beware, this is implemented inefficiently. It should be used
      # for debugging only.
      def line
        string[0..pos].count("\n") + 1
      end
      
      # The current column position of the scanner. See also #line.
      #
      # Beware, this is implemented inefficiently. It should be used
      # for debugging only.
      def column pos = self.pos
        return 0 if pos <= 0
        string = string()
        if string.respond_to?(:bytesize) && (defined?(@bin_string) || string.bytesize != string.size)
          @bin_string ||= string.dup.force_encoding('binary')
          string = @bin_string
        end
        pos - (string.rindex(?\n, pos) || 0)
      end
      
      def marshal_dump  # :nodoc:
        @options
      end
      
      def marshal_load options  # :nodoc:
        @options = options
      end

    protected

      # Can be implemented by subclasses to do some initialization
      # that has to be done once per instance.
      #
      # Use reset for initialization that has to be done once per
      # scan.
      def setup  # :doc:
      end

      # This is the central method, and commonly the only one a
      # subclass implements.
      #
      # Subclasses must implement this method; it must return +tokens+
      # and must only use Tokens#<< for storing scanned tokens!
      def scan_tokens tokens, options  # :doc:
        raise NotImplementedError,
          "#{self.class}#scan_tokens not implemented."
      end
      
      # Resets the scanner.
      def reset_instance
        @tokens.clear if @tokens.respond_to?(:clear) && !@options[:keep_tokens]
        @cached_tokens = nil
        @bin_string = nil if defined? @bin_string
      end

      # Scanner error with additional status information
      def raise_inspect msg, tokens, state = 'No state given!', ambit = 30
        raise ScanError, <<-EOE % [


***ERROR in %s: %s (after %d tokens)

tokens:
%s

current line: %d  column: %d  pos: %d
matched: %p  state: %p
bol? = %p,  eos? = %p

surrounding code:
%p  ~~  %p


***ERROR***

        EOE
          File.basename(caller[0]),
          msg,
          tokens.size,
          tokens.last(10).map { |t| t.inspect }.join("\n"),
          line, column, pos,
          matched, state, bol?, eos?,
          string[pos - ambit, ambit],
          string[pos, ambit],
        ]
      end

    end

  end
end