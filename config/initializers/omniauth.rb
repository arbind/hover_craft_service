if defined?(Rails::Server) and SECRET::TWITTER::KEY == LOCAL::TWITTER::KEY
  puts ":: Twitter OAuth using: http://0.0.0.0:#{Rails::Server.new.options[:Port]}"
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, TWITTER[:KEY], TWITTER[:SECRET]
end