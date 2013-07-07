PING_INTERVAL = 8*60 # in seconds

module BackgroundPing
  def self.start
    ping_uri = URI.parse("#{ENV['APPLICATION_URL']}/ping")
    interval = PING_INTERVAL
    description = "Ping #{ping_uri} every #{PING_INTERVAL} minutes"
    puts ":: Launched Thread to #{description}"
    ping_thread = Thread.new do
      Thread.current[:name] = :ping
      Thread.current[:description] = description
      sleep DELAY_STARTUP_OF_BACKGROUND_THREADS
      loop do
        sleep interval
        begin
          Net::HTTP.get_response(ping_uri)
        rescue Exception => ex
          puts ex.message
        end
      end
    end
  end
end

BackgroundPing.start if LAUNCH_BACKGROUND_THREADS