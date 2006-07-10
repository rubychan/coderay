desc 'Report code statistics (LOC) from the application'
task :stats do
  require 'rake_helpers/code_statistics'
  CodeStatistics.new(
    ['Main', 'lib'],
    ['CodeRay', 'lib/{.,coderay}/'],
    ['  Scanners', 'lib/coderay/scanners/**'],
    ['  Encoders', 'lib/coderay/encoders/**'],
    ['  Helpers', 'lib/coderay/helpers/**'],
    ['  Styles', 'lib/coderay/styles/**'],
    ['Test', 'test'],
    ['  Test Data', 'test/*/**', /\.in\./, false],
    ['Demo Tests', 'demo/**']
  ).print
end
