module CodeRay

  # This module holds the Style class and its subclasses.
  # 
  # See Plugin.
  module Styles
    extend PluginHost
    plugin_path File.dirname(__FILE__), 'styles'
  end
  
end
