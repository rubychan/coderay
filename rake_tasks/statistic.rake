desc 'Report code statistics (LOC) from the application'
task :stats do
  require './rake_tasks/code_statistics'
  CodeStatistics.new(
    ['Main', 'lib', /coderay.rb$/],
    ['CodeRay', 'lib/coderay/'],
    ['  Scanners', 'lib/coderay/scanners/**'],
    ['  Encoders', 'lib/coderay/encoders/**'],
    ['  Helpers', 'lib/coderay/helpers/**'],
    ['  Styles', 'lib/coderay/styles/**'],
    ['Executable', 'bin', /coderay$/],
    ['Executable Tests', 'test/executable/**'],
    ['Functional Tests', 'test/functional/**'],
    ['Scanner Tests', 'test/scanners/**', /suite\.rb$/],
    ['Unit Tests', 'test/unit/**'],
    # ['  Test Data', 'test/scanners/**', /\.in\./, false],
    ['Demos', 'sample/**']
  ).print
end
