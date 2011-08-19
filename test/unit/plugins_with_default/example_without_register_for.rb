class ExampleWithoutRegisterFor < PluginScannerTest::PluginsWithDefault::Plugin
  
  register_for :wrong_id
  
end
