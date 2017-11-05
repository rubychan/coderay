require 'set'
require 'coderay/simple_scanner_dsl'

module CodeRay
  module Scanners
    class SimpleScanner < Scanner
      extend SimpleScannerDSL

      class << self
        def define_scan_tokens!
          if ENV['PUTS']
            puts CodeRay.scan(scan_tokens_code, :ruby).terminal
            puts "callbacks: #{callbacks.size}"
          end

          class_eval <<-RUBY
def scan_tokens encoder, options
#{ scan_tokens_code.chomp.gsub(/^/, '  ' * 2) }
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
        @state = :initial
      end

      def close_groups encoder, states
        # TODO
      end
    end
  end
end