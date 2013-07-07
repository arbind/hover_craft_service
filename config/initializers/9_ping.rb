PING_INTERVAL = 8 # in minutes

module BackgroundPing
  def self.start
    ping_uri = URI.parse("#{ENV['APPLICATION_URL']}/ping")
    puts ":: Ping #{ping_uri} every #{PING_INTERVAL} minutes"
    ping_thread = Thread.new do
      Thread.current[:name] = :ping
      Thread.current[:description] = "Pings server every #{PING_INTERVAL} minutes"
      loop do
        sleep PING_INTERVAL*60
        Net::HTTP.get_response(ping_uri)
      end
    end
  end
end

BackgroundPing.start if LAUNCH_BACKGROUND_THREADS