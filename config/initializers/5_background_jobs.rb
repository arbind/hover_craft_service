
# How often to look for new TwitterCrafts (friends_ids of a TweetStreamer)
TWEET_STREAMER_REFRESH_INTERVAL = 10 #*60 # seconds

TWITTER_REQUEST_INTERVAL = {
  refresh_all_tweet_streamers: TWEET_STREAMER_REFRESH_INTERVAL,
  tweet_streamer: INTERVAL_FOR_TWITTER_RATE_LIMITS[:friend_ids],
  twitter_craft:  INTERVAL_FOR_TWITTER_RATE_LIMITS[:users],
}

TWITTER_JOB_THREADS = {}

module BackgroundTwitterJobs

  def self.refresh_all_tweet_streamers
    key = :refresh_all_tweet_streamers
    return if TWITTER_JOB_THREADS[key]
    interval = TWITTER_REQUEST_INTERVAL[key]
    description = "Refresh TweetStreamers every #{interval} seconds"
    puts ":: Launched Thread to #{description}"
    TWITTER_JOB_THREADS[key] = Thread.new do
      Thread.current[:name] = key
      Thread.current[:description] = description
      sleep DELAY_STARTUP_OF_BACKGROUND_THREADS
      loop do
        sleep interval
        puts ":: #{description}"
        begin
          TwitterJobs.refresh_all_tweet_streamers
        rescue Exception => ex
          puts ex.message
        end
      end
    end
  end

  def self.process_job(key)
    return if TWITTER_JOB_THREADS[key]
    interval = TWITTER_REQUEST_INTERVAL[key]
    description = "Process :#{key} job every #{interval} seconds"
    puts ":: Launched Thread to #{description}"
    TWITTER_JOB_THREADS[key] = Thread.new do
      Thread.current[:name] = key
      Thread.current[:description] = description
      sleep DELAY_STARTUP_OF_BACKGROUND_THREADS
      loop do
        sleep interval
        puts ":: #{description}"
        begin
          TwitterJobs.process_next_job key
        rescue Exception => ex
          puts ex.message
        end
      end
    end
  end
end

if LAUNCH_BACKGROUND_THREADS
  # Queue all Tweet Streamers to be refreshed
  BackgroundTwitterJobs.refresh_all_tweet_streamers
  # Pull friends ids from TweetStreamer and queue each to become a TwitterCraft
  BackgroundTwitterJobs.process_job(:tweet_streamer)
  # Pull a twitter user as a new TwitterCraft (creating a Root HoverCraft)
  BackgroundTwitterJobs.process_job(:twitter_craft)
end