ENV["IN_RAKE"]    = "YES" if $0.end_with?('rake')
ENV["IN_CONSOLE"] = "YES" if defined?(Rails::Console)
ENV["IN_SERVER"]  = "YES" unless (ENV["IN_CONSOLE"] or ENV["IN_RAKE"] or Rails.env.test?)

puts ":: Running in server"     if ENV["IN_SERVER"]
puts ":: Running in rake task"  if ENV["IN_RAKE"]
puts ":: Running in console"    if ENV["IN_CONSOLE"]
