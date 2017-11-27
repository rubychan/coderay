require 'set'
require 'coderay/rouge_scanner_dsl'

module CodeRay
  module Scanners
    class RougeScanner < Scanner
      require 'rouge'
      include Rouge::Token::Tokens

      extend RougeScannerDSL

      class << self
        def define_scan_tokens!
          if ENV['PUTS']
            puts CodeRay.scan(scan_tokens_code, :ruby).terminal
            puts "callbacks: #{callbacks.size}"
          end

          class_eval <<-RUBY
def scan_tokens encoder, options
  @encoder = encoder
#{ scan_tokens_code.chomp.gsub(/^/, '  ') }
end
          RUBY
        end
      end

      def scan_tokens tokens, options
        self.class.define_scan_tokens!

        scan_tokens tokens, options
      end

      protected

      def setup
        @state = :root
      end

      def close_groups encoder, states
        # TODO
      end

      def token token
        @encoder.text_token @match, token
      end
    end
  end
end