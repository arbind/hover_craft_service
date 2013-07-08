
module BackgroundTwitterJobs
  # Allow time for the server to start up before kicking off the thread
  @options = { launch_delay: ENV["STARTUP_DELAY_OF_BACKGROUND_THREADS"].to_i }

  # queue jobs to :pull_streamer_friend_ids
  # only run if all other twitter jobs have completed
  def self.launch_job_to_pull_twitter_crafts_from_all_streamers
    key = :refresh_all_tweet_streamers
    interval = ENV["TWEET_STREAMER_REFRESH_INTERVAL"] || 30 #10*60 # seconds
    BackgroundThreads.launch key, interval, @options do
      unless JobQueue.any_jobs_for_group?(:twitter)
        TwitterJobs.pull_twitter_crafts_from_all_streamers
      else
        puts ":: skipped refresh_all_tweet_streamers: twitter jobs still running"
      end
    end
  end

  # Pull TweetStreamer friend_ids and look for any new friends
  # Queue newfound friends to :create_hover_crafts_for_streamer_friends
  def self.launch_job_to_pull_streamer_friend_ids
    key = :pull_streamer_friend_ids
    interval = INTERVAL_FOR_TWITTER_RATE_LIMITS[:friend_ids]
    BackgroundThreads.launch key, interval, @options do
      TwitterJobs.process_next_job key
    end
  end

  # Populate new HoverCraft with Twitter info (of a streamer friend)
  def self.launch_job_to_create_hover_crafts_for_streamer_friends
    key = :create_hover_crafts_for_streamer_friends
    interval = INTERVAL_FOR_TWITTER_RATE_LIMITS[:users]
    BackgroundThreads.launch key, interval, @options do
      TwitterJobs.process_next_job key
    end
  end
end

if ENV["LAUNCH_BACKGROUND_THREADS"]
  BackgroundTwitterJobs.launch_job_to_pull_twitter_crafts_from_all_streamers
  BackgroundTwitterJobs.launch_job_to_pull_streamer_friend_ids
  BackgroundTwitterJobs.launch_job_to_create_hover_crafts_for_streamer_friends
end