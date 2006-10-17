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
    ['Functional Tests', 'test/functional/**'],
    ['Scanner Tests', 'test/scanners/**', /suite\.rb$/],
    #['  Test Data', 'test/scanners/**', /\.in\./, false],
    ['Demo Tests', 'sample/**']
  ).print
end
