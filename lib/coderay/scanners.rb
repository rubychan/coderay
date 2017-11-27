require 'strscan'

module CodeRay
  
  autoload :WordList, coderay_path('helpers', 'word_list')
  
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
    
    autoload :Scanner, CodeRay.coderay_path('scanners', 'scanner')

    # DSL Scanners
    autoload :RuleBasedScanner, CodeRay.coderay_path('rule_based_scanner')
    autoload :SingleStateRuleBasedScanner, CodeRay.coderay_path('single_state_rule_based_scanner')
    autoload :StateBasedScanner, CodeRay.coderay_path('state_based_scanner')
    autoload :RougeScanner, CodeRay.coderay_path('rouge_scanner')
    autoload :SimpleScanner, CodeRay.coderay_path('simple_scanner')
    
  end
  
end
