class WorkerCreateHoverCraftsForNewStreamerFriends

  include Sidekiq::Worker
  include Sidekiq::ScheduledWorker
  @perform_after = INTERVAL_FOR_TWITTER_RATE_LIMITS[:users]

  def self.work_data(streamer_id, friend_ids)
    {
      "streamer_id" => streamer_id.to_s,
      "friend_ids"  => friend_ids
    }
  end

  def perform(data)
    streamer_id = data.fetch 'streamer_id'
    friend_ids = data.fetch 'friend_ids'
    twitter_profiles = twitter_profiles_for_new_streamer_friends streamer_id, friend_ids
    hover_craft_ids = create_hover_crafts_for_twitter_profiles streamer_id, twitter_profiles
    resolve_twitter_website_urls hover_craft_ids
  end

private
  def twitter_profiles_for_new_streamer_friends(streamer_id, friend_ids)
    batches_of_ids = friend_ids.each_slice(batch_size).to_a
    ids = batches_of_ids.shift
    reschedule_in_batches streamer_id, batches_of_ids
    fetch_twitter_profiles ids
  end

  def create_hover_crafts_for_twitter_profiles(streamer_id, twitter_profiles)
    hover_craft_ids = []
    twitter_profiles.each do |profile|
      params = profile.to_hover_craft
      params[:tweet_streamer] = TweetStreamer.find streamer_id
      hover_craft = HoverCraft.where(twitter_id: params[:twitter_id]).first_or_create
      hover_craft.update_attributes params
      hover_craft_ids.push hover_craft.id
    end
    log({ hover_crafts:hover_craft_ids.count })
    hover_craft_ids
  end

  def resolve_twitter_website_urls(hover_craft_ids)
    hover_craft_ids.each do |hc_id|
      job_data = WorkerResolveHoverCraftUrl.work_data hc_id, :twitter_website_url
      WorkerResolveHoverCraftUrl.schedule job_data
    end
  end

  def reschedule_in_batches(streamer_id, batches_of_ids)
    batches_of_ids.each do |ids|
      job_data = self.class.work_data streamer_id, ids
      self.class.schedule job_data
    end
  end

  def fetch_twitter_profiles(ids)
    TwitterApi.service.users(ids)
  end

  def batch_size
    TWITTER_FETCH_USERS_BATCH_SIZE
  end

  def log(info)
    msg = "#{info[:hover_crafts]} HoverCrafs created!"
    Rails.logger.info msg
  end
end