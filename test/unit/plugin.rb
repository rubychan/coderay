require 'test/unit'
require 'pathname'

$:.unshift File.expand_path('../../../lib', __FILE__)
require 'coderay'

class PluginScannerTest < Test::Unit::TestCase
  
  module Plugins
    extend CodeRay::PluginHost
    plugin_path File.dirname(__FILE__), 'plugins'
    class Plugin
      extend CodeRay::Plugin
      plugin_host Plugins
    end
  end
  
  module PluginsWithDefault
    extend CodeRay::PluginHost
    plugin_path File.dirname(__FILE__), 'plugins_with_default'
    class Plugin
      extend CodeRay::Plugin
      plugin_host PluginsWithDefault
    end
    default :default_plugin
  end
  
  def test_load
    require Pathname.new(__FILE__).realpath.dirname + 'plugins' + 'user_defined' + 'user_plugin'
    assert_equal 'UserPlugin', Plugins.load(:user_plugin).name
  end
  
  def test_load_all
    assert_instance_of Symbol, Plugins.load_all.first
    assert_operator Plugins.all_plugins.first, :<, Plugins::Plugin
    assert_equal 'The Example', Plugins.all_plugins.map { |plugin| plugin.title }.sort.first
  end
  
  def test_default
    assert_nothing_raised do
      assert_operator PluginsWithDefault[:gargamel], :<, PluginsWithDefault::Plugin
    end
    assert_equal PluginsWithDefault::Default, PluginsWithDefault.default
  end
  
  def test_plugin_not_found
    assert_raise CodeRay::PluginHost::PluginNotFound do
      Plugins[:thestral]
    end
    assert_raise ArgumentError do
      Plugins[14]
    end
    assert_raise ArgumentError do
      Plugins['test/test']
    end
    assert_raise CodeRay::PluginHost::PluginNotFound do
      PluginsWithDefault[:example_without_register_for]
    end
  end
  
  def test_autoload_constants
    assert_operator Plugins::Example, :<, Plugins::Plugin
  end
  
  def test_title
    assert_equal 'The Example', Plugins::Example.title
  end
  
end
