# A little hack to enable CodeRay highlighting in RedCloth.

module CodeRay
  
  # A little hack to enable CodeRay highlighting in RedCloth.
  # 
  # Usage:
  #  require 'coderay'
  #  CodeRay.for_redcloth
  #  RedCloth.new('@[ruby]puts "Hello, World!"@').to_html
  # 
  # Make sure you have RedCloth 4.0.3 activated, for example by calling
  #  require 'rubygems'
  # before RedCloth is loaded and before calling CodeRay.for_redcloth.
  def self.for_redcloth
    gem 'RedCloth', '>= 4.0.3' rescue nil
    require 'redcloth'
    raise 'CodeRay.for_redcloth needs RedCloth 4.0.3 or later.' unless RedCloth::VERSION.to_s >= '4.0.3'
    RedCloth::TextileDoc.send :include, ForRedCloth::TextileDoc
    RedCloth::Formatters::HTML.module_eval do
      undef_method :code, :bc_open, :bc_close
      def code(opts)
        opts[:block] = true
        if opts[:lang] && !filter_coderay
          require 'coderay'
          @in_bc ||= nil
          format = @in_bc ? :div : :span
          highlighted_code = CodeRay.encode opts[:text], opts[:lang], format, :stream => true
          highlighted_code.sub(/\A<(span|div)/) { |m| m + pba(@in_bc || opts) }
        else
          "<code#{pba(opts)}>#{opts[:text]}</code>"
        end
      end
      def bc_open(opts)
        opts[:block] = true
        @in_bc = opts
        opts[:lang] ? '' : "<pre#{pba(opts)}>"
      end
      def bc_close(opts)
        @in_bc = nil
        opts[:lang] ? '' : "</pre>\n"
      end
    end
  end
  
  module ForRedCloth # :nodoc:
    
    module TextileDoc # :nodoc:
      attr_accessor :filter_coderay
    end
    
  end
  
end
