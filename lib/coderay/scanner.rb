module CodeRay

  # This module holds class Scanner and its subclasses.
  # For example, the Ruby scanner is named CodeRay::Scanners::Ruby
  # can be found in coderay/scanners/ruby.
  # 
  # Scanner also provides methods and constants for the register
  # mechanism and the [] method that returns the Scanner class
  # belonging to the given lang.
  module Scanners

    # Raised if Scanners[] fails because:
    # * a file could not be found
    # * the requested Scanner is not registered
    ScannerNotFound = Class.new(Exception)

    # Loaded Scanners are saved here.
    SCANNERS = Hash.new { |h, lang|
      raise ScannerNotFound, "No scanner for #{lang} found."
    }

    class << self

      # Registers a scanner class by setting SCANNERS[lang].
      #
      # Typically used in Scanners, for example in the Ruby scanner:
      #
      #   register_for :ruby
      def register scanner_class, *langs
        for lang in langs
          unless lang.is_a? Symbol
            raise ArgumentError,
              "lang must be a Symbol, but it was a #{lang.class}"
          end
          SCANNERS[lang] = scanner_class
        end
      end

      # Loads the scanner class for +lang+ and returns it.
      #
      # Example:
      #
      #   Scanners[:xml].new
      #
      # +lang+ is converted using +normalize+ and must be
      # * a String containing only alphanumeric characters (\w+)
      # * a Symbol
      #
      # Strings are converted to lowercase symbols (so +'C'+ and +'c'+
      # load the same scanner, namely the one registered for +:c+.)
      # 
      # If the scanner isn't registered yet, it is searched.
      # CodeRay expects that the scanner class is defined in
      #
      #   <install-dir>/coderay/scanners/<lang>.rb
      #
      # (See path_to.)
      #
      # If the file isn't found, a ScannerNotFound exception is raised
      #
      # The scanner should register itself using +register+. If the
      # scanner is still not found (because has not registered or
      # registered under another
      # lang), a ScannerNotFound exception is raised.
      def [] lang
        lang = normalize lang

        SCANNERS.fetch lang do
          scanner_file = path_to lang

          begin
            require scanner_file
          rescue LoadError
            raise ScannerNotFound, "File #{scanner_file} not found."
          end

          SCANNERS.fetch lang do
            raise ScannerNotFound, <<-ERR
No scanner for #{lang} found in #{scanner_file}.
Known scanners: #{SCANNERS}
            ERR
          end
        end
      end

      # Alias for +[]+.
      alias load []

      # Calculates the path where a scanner for +lang+
      # is expected to be. This is:
      # 
      #   <install-dir>/coderay/scanners/<lang>.rb
      def path_to lang
        File.join 'coderay', 'scanners', "#{lang}.rb"
      end

      # Returns an array of all filenames in the scanners/ folder.
      # The extension +.rb+ is not included.
      def languages
        scanners = File.join File.dirname(__FILE__), 'scanners', '*.rb'
        Dir[scanners].map do |file|
          File.basename file, '.rb'
        end
      end

      # Loads all scanners that +languages+ finds using +load+.
      def load_all
        for lang in languages
          load lang
        end
      end

      # Converts +lang+ to a downcase Symbol if it is a String,
      # or returns +lang+ if it already is a Symbol.
      #
      # Raises +ArgumentError+ for all other objects, or if the
      # given String includes non-alphanumeric characters (\W).
      def normalize lang
        if lang.is_a? Symbol
          lang
        elsif lang.is_a? String
          if lang[/\w+/] == lang
            lang[/\w+/].downcase.to_sym
          else
            raise ArgumentError, "Invalid lang: '#{lang}' given."
          end
        elsif lang.nil?
          :plaintext
        else
          raise ArgumentError,
            "String or Symbol expected, but #{lang.class} given."
        end
      end

    end


    require 'strscan'
    # = Scanner
    #
    # The base class for all Scanners.
    #
    # It is a subclass of Ruby's great +StringScanner+, which
    # makes it easy to access the scanning methods inside.
    #
    # It is also +Enumerable+, so you can use it like an Array of Tokens:
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

      # Raised if a Scanner fails while scanning
      ScanError = Class.new(Exception)

      require 'coderay/helpers/scanner_helper'

      # The default options for all scanner classes.
      # 
      # Define @default_options for subclasses.
      DEFAULT_OPTIONS = { :stream => false }

      class << self
        # Register the scanner class for all
        # +langs+.
        #
        # See Scanners.register.
        def register_for *langs
          Scanners.register self, *langs
        end

        # Returns if the Scanner can be used in streaming mode.
        def streamable?
          is_a? Streamable
        end

      end

=begin
      ## Excluded for speed reasons; protected seems to make methods slow.

      # Save the StringScanner methods from being called.
      # This would not be useful for highlighting.
strscan_public_methods =
  StringScanner.instance_methods - StringScanner.ancestors[1].instance_methods
protected(*strscan_public_methods)
=end

      # Creates a new Scanner.
      #
      # * +code+ is the input String and is handled by the superclass
      #   StringScanner.
      # * +options+ is a Hash with Symbols as keys.
      #   It is merged with the default options of the class (you can
      #   overwrite default options here.)
      # * +block+ is the callback for streamed highlighting.
      #
      # If you set :stream to +true+ in the options, the Scanner uses a
      # TokenStream with the +block+ as callback to handle the tokens.
      #
      # Else, a Tokens object is used.
      def initialize code, options = {}, &block
        @options = self.class::DEFAULT_OPTIONS.merge options
        raise "I am only the basic Scanner class. I can't scan anything. :(\n" + 
          "Use my subclasses." if self.class == Scanner

        # I love this hack. It seems to silence
        # all dos/unix/mac newline problems.
        super code.gsub(/\r\n?/, "\n")

        if @options[:stream]
          warn "warning in CodeRay::Scanner.new: :stream is set, "\
            "but no block was given" unless block_given?
          raise NotStreamableError, self unless kind_of? Streamable
          @tokens = TokenStream.new(&block)
        else
          warn "warning in CodeRay::Scanner.new: Block given, "\
            "but :stream is #{@options[:stream]}" if block_given?
          @tokens = Tokens.new
        end
      end

      # More mnemonic accessor name for the input string.
      alias code string

      # Scans the code and returns all tokens in a Tokens object.
      def tokenize options = {}
        options = @options.merge({}) #options
        if @options[:stream]  # :stream must have been set already
          reset ## what is this for?
          scan_tokens @tokens, options
          @tokens
        else
          @cached_tokens ||= scan_tokens @tokens, options
        end
      end

      # you can also see this as a read-only attribute
      alias tokens tokenize

      # Traverses the tokens.
      def each &block
        raise ArgumentError, 
          'Cannot traverse TokenStream.' if @options[:stream]
        tokens.each(&block)
      end
      include Enumerable

      # The current line position of the scanner.
      #
      # Beware, this is implemented inefficiently. It should be used
      # for debugging only.
      def line
        string[0..pos].count("\n") + 1
      end

      protected

      # This is the central method, and commonly the only one a subclass
      # implements.
      # 
      # Subclasses must implement this method; it must return +tokens+
      # and must only use Tokens#<< for storing scanned tokens!
      def scan_tokens tokens, options
        raise NotImplementedError, "#{self.class}#scan_tokens not implemented."
      end

      # Scanner error with additional status information
      def raise_inspect msg, tokens, ambit = 30
        raise ScanError, <<-EOE % [


***ERROR in %s: %s

tokens:
%s

current line: %d  pos = %d
matched: %p
bol? = %p,  eos? = %p

surrounding code:
%p  ~~  %p


***ERROR***

        EOE
        File.basename(caller[0]),
        msg,
        tokens.last(10).map { |t| t.inspect }.join("\n"),
        line, pos,
        matched, bol?, eos?,
        string[pos-ambit,ambit],
        string[pos,ambit],
        ]
      end

    end

  end
end

# vim:sw=2:ts=2:noet:tw=78
