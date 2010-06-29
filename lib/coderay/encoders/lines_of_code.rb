module CodeRay
module Encoders
  
  # Counts the LoC (Lines of Code). Returns an Integer >= 0.
  # 
  # Alias: +loc+
  # 
  # Everything that is not comment, markup, doctype/shebang, or an empty line,
  # is considered to be code.
  # 
  # For example,
  # * HTML files not containing JavaScript have 0 LoC
  # * in a Java class without comments, LoC is the number of non-empty lines
  # 
  # A Scanner class should define the token kinds that are not code in the
  # KINDS_NOT_LOC constant, which defaults to [:comment, :doctype].
  class LinesOfCode < Encoder
    
    register_for :lines_of_code
    
    NON_EMPTY_LINE = /^\s*\S.*$/
    
  protected
    
    def compile tokens, options
      if scanner = tokens.scanner
        kinds_not_loc = scanner.class::KINDS_NOT_LOC
      else
        warn "Tokens have no associated scanner, counting all nonempty lines." if $VERBOSE
        kinds_not_loc = CodeRay::Scanners::Scanner::KINDS_NOT_LOC
      end
      code = tokens.token_kind_filter :exclude => kinds_not_loc
      @loc = code.to_s.scan(NON_EMPTY_LINE).size
    end
    
    def finish options
      @loc
    end
    
  end
  
end
end
