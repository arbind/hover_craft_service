PING_INTERVAL = 8*60 # seconds

module BackgroundPing
  def self.start
    ping_uri = URI.parse("#{ENV['APPLICATION_URL']}/ping")

    # Allow time for the server to start up before kicking off the thread
    options = { launch_delay: ENV["STARTUP_DELAY_OF_BACKGROUND_THREADS"] }
    key = :ping
    interval = PING_INTERVAL
    BackgroundThreads.launch key, interval, options do
      Net::HTTP.get_response(ping_uri)
    end
  end
end

BackgroundPing.start if ENV["LAUNCH_BACKGROUND_JOBS"]