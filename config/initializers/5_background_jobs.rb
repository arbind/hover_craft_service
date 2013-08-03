
module BackgroundJobs
  # Allow time for the server to start up before kicking off the thread


  def self.delay_launch(seconds)
    { launch_delay: (seconds+ENV["STARTUP_DELAY_OF_BACKGROUND_THREADS"].to_i) }
  end

  # queue jobs to :pull_streamer_friend_ids
  # only run if all other twitter jobs have completed
  def self.launch_job_to_pull_twitter_crafts_from_all_streamers
    key = :refresh_all_tweet_streamers
    interval = ENV["TWEET_STREAMER_REFRESH_INTERVAL"] || 30 #10*60 # seconds
    BackgroundThreads.launch key, interval, delay_launch(0) do
      unless JobQueue.any_jobs_for_group?(:yelp)
          YelpJobs.pull_yelp_craft_for_new_twitter_crafts
      else
        puts ":: skipped pull_yelp_craft_for_new_twitter_crafts: yelp jobs still running"
      end
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
    BackgroundThreads.launch key, interval, delay_launch(4) do
      TwitterJobs.process_next_job key
    end
  end

  # Populate new HoverCraft with Twitter info (of a streamer friend)
  def self.launch_job_to_create_hover_crafts_for_streamer_friends
    key = :create_hover_crafts_for_streamer_friends
    interval = INTERVAL_FOR_TWITTER_RATE_LIMITS[:users]
    BackgroundThreads.launch key, interval, delay_launch(8) do
      TwitterJobs.process_next_job key
    end
  end

  # Populate new HoverCraft with Yelp info
  def self.launch_job_to_pull_yelp_craft_for_twitter
    key = :pull_yelp_craft_for_twitter
    interval = INTERVAL_FOR_YELP_RATE_LIMIT
    BackgroundThreads.launch key, interval, delay_launch(12) do
      YelpJobs.process_next_job key
    end
  end

  def self.launch_job_to_find_final_location_of_twitter_website_url
    key = :find_final_location_of_twitter_website_url
    interval = 8
    BackgroundThreads.launch key, interval, delay_launch(20) do
      hover_crafts = HoverCraft.where(twitter_website_url: /t\.co/)
      hover_crafts.each do |hover_craft|
        url = nil
        begin
          puts hover_craft.twitter_website_url
          url = Web.final_location_of_url hover_craft.twitter_website_url
        rescue Exception => e
          puts ":: Error to #{key} for #{hover_craft.twitter_website_url}"
          puts e.message
          puts e.inspect
        ensure
          hover_craft.update_attributes({twitter_website_url: url}) if url
        end
      end
    end
  end
end

if ENV["LAUNCH_BACKGROUND_THREADS"]
  BackgroundJobs.launch_job_to_pull_twitter_crafts_from_all_streamers
  BackgroundJobs.launch_job_to_pull_streamer_friend_ids
  BackgroundJobs.launch_job_to_create_hover_crafts_for_streamer_friends
  BackgroundJobs.launch_job_to_pull_yelp_craft_for_twitter
  BackgroundJobs.launch_job_to_find_final_location_of_twitter_website_url
end