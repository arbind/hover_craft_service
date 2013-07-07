module LOCAL    # dev config for running on localhost
  module TWITTER
    KEY     = "6QOEygXZwne9IXahN0STtQ"
    SECRET  = "EmotufoC4hdWpURUHWy5xhGSH25ZDtmPCTLsK72A"
  end
end

module SECRET
  module TWITTER
    KEY     = ENV["TWITTER_KEY"]    || LOCAL::TWITTER::KEY
    SECRET  = ENV["TWITTER_SECRET"] || LOCAL::TWITTER::SECRET
  end
end


ENV["APPLICATION_URL"] ||= "http://0.0.0.0:3000"

ENV["IN_RAKE"]    = "YES" if $0.end_with?('rake')
ENV["IN_CONSOLE"] = "YES" if defined?(Rails::Console)
ENV["IN_SERVER"]  = "YES" unless (ENV["IN_CONSOLE"] or ENV["IN_RAKE"])

puts ":: Running in server"     if ENV["IN_SERVER"]
puts ":: Running in rake task"  if ENV["IN_RAKE"]
puts ":: Running in console"    if ENV["IN_CONSOLE"]

LAUNCH_BACKGROUND_THREADS = ENV["IN_SERVER"] and !Rails.env.test?