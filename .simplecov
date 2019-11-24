unless RUBY_VERSION[/^2.3/]
  SimpleCov.command_name $0
  SimpleCov.start
end
