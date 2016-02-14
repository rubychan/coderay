module CodeRay
module Scanners

  class CSS2 < RuleBasedScanner
    
    register_for :css2
    
    KINDS_NOT_LOC = [
      :comment,
      :class, :pseudo_class, :tag,
      :id, :directive,
      :key, :value, :operator, :color, :float, :string,
      :error, :important, :type,
    ]  # :nodoc:
    
    module RE  # :nodoc:
      Hex = /[0-9a-fA-F]/
      Unicode = /\\#{Hex}{1,6}\b/ # differs from standard because it allows uppercase hex too
      Escape = /#{Unicode}|\\[^\n0-9a-fA-F]/
      NMChar = /[-_a-zA-Z0-9]/
      NMStart = /[_a-zA-Z]/
      String1 = /(")((?:[^\n\\"]+|\\\n|#{Escape})+)?(")?/  # TODO: buggy regexp
      String2 = /(')((?:[^\n\\']+|\\\n|#{Escape})+)?(')?/  # TODO: buggy regexp
      String = /#{String1}|#{String2}/
      
      HexColor = /#(?:#{Hex}{6}|#{Hex}{3})/
      
      Num = /-?(?:[0-9]*\.[0-9]+|[0-9]+)n?/
      Name = /#{NMChar}+/
      Ident = /-?#{NMStart}#{NMChar}*/
      AtKeyword = /@#{Ident}/
      Percentage = /#{Num}%/
      
      reldimensions = %w[em ex px]
      absdimensions = %w[in cm mm pt pc]
      Unit = Regexp.union(*(reldimensions + absdimensions + %w[s dpi dppx deg]))
      
      Dimension = /#{Num}#{Unit}/
      
      Function = /((?:url|alpha|attr|counters?)\()((?:[^)\n]|\\\))+)?(\))?/
      
      Id = /(?!#{HexColor}\b(?!-))##{Name}/
      Class = /\.#{Name}/
      PseudoClass = /::?#{Ident}/
      AttributeSelector = /(\[)([^\]]+)?(\])?/
    end
    
    state :initial do
      on %r/\s+/, :space
      
      on check_if(:block), check_if(:value_expected), %r/(?>#{RE::Ident})(?!\()/x, :value
      on check_if(:block), %r/(?>#{RE::Ident})(?!\()/x, :key
      
      on check_unless(:block), %r/(?>#{RE::Ident})(?!\()|\*/x, :tag
      on check_unless(:block), RE::Class, :class
      on check_unless(:block), RE::Id, :id
      on check_unless(:block), RE::PseudoClass, :pseudo_class
      # TODO: Improve highlighting inside of attribute selectors.
      on check_unless(:block), RE::AttributeSelector, groups(:operator, :attribute_name, :operator)
      on check_unless(:block), %r/(@media)(\s+)?(#{RE::Ident})?(\s+)?(\{)?/, groups(:directive, :space, :type, :space, :operator)
      
      on %r/\/\*(?:.*?\*\/|\z)/m, :comment
      on %r/\{/, :operator, flag_off(:value_expected), flag_on(:block)
      on %r/\}/, :operator, flag_off(:value_expected), flag_off(:block)
      on RE::String1, push(:string), groups(:delimiter, :content, :delimiter), pop
      on RE::String2, push(:string), groups(:delimiter, :content, :delimiter), pop
      on RE::Function, push(:function), groups(:delimiter, :content, :delimiter), pop
      on %r/(?: #{RE::Dimension} | #{RE::Percentage} | #{RE::Num} )/x, :float
      on RE::HexColor, :color
      on %r/! *important/, :important
      on %r/(?:rgb|hsl)a?\([^()\n]*\)?/, :color
      on RE::AtKeyword, :directive
      on %r/:/, :operator, flag_on(:value_expected)
      on %r/;/, :operator, flag_off(:value_expected)
      on %r/ [+>~,.=()\/] /x, :operator
    end
    
    protected
    
    def setup
      super
      
      @value_expected = false
      @block = false
    end
    
  end
  
end
end
