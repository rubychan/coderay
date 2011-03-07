task 'ruby:version' do
  puts
  if defined? RUBY_DESCRIPTION
    ruby_version = RUBY_DESCRIPTION
  else
    ruby_version = "ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE} patchlevel #{RUBY_PATCHLEVEL}) [#{RUBY_PLATFORM}]"
  end
  require './test/lib/term/ansicolor'
  puts Term::ANSIColor.bold(Term::ANSIColor.green(ruby_version))
end