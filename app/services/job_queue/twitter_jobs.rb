# assumes all friends of a TweetStreamer are verified TwitterCrafts
class TwitterJobs
  def service
    self
  end

  def self.process_next_job(key)
    entry = JobQueue.dequeue key
    process entry if entry
  end

  def self.refresh_all_tweet_streamers
    TweetStreamer.all.each do |tweet_streamer|
      refresh_tweet_streamer tweet_streamer
    end
  end

  def self.refresh_tweet_streamer(tweet_streamer)
    pull_streamer_friend_ids tweet_streamer.screen_name
  end

private

  # Queue job to find any new TweetStreamer friends
  def self.pull_streamer_friend_ids(screen_name, cursor = -1)
    key = :pull_streamer_friend_ids
    return unless screen_name
    group = :twitter
    uid   = screen_name
    job   = { screen_name: screen_name, cursor: cursor }
    JobQueue.enqueue(key, uid, job, group)
  end

  # Queue newfound friends of TweetStreamers to become new HoverCrafts
  def self.q_create_hover_crafts_for_streamer_friends(twitter_ids)
    key   = :create_hover_crafts_for_streamer_friends
    return unless twitter_ids and twitter_ids.any?
    group = :twitter

    batch_of_100_ids = twitter_ids.each_slice(100).to_a
    p "batch_of_100_ids"
    p batch_of_100_ids
    batch_of_100_ids.each do |ids_for_100_friends|
      uid   = ids_for_100_friends.first
      job   = { twitter_ids: ids_for_100_friends }
      JobQueue.enqueue(key, uid, job, group)
    end
  end

  def self.process(entry)
    method ="process_#{entry[:key]}".to_sym
    send method, entry[:job]
  end

  # Job Processors

  # Process job to find any new TweetStreamer friends
  # 1. Pull friends ids from TweetStreamer
  # 2. detect new friends
  # 3. queue newfound friends to become a HoverCraft
  def self.process_pull_streamer_friend_ids(job)
    streamer_tid = job['screen_name']
    next_cursor = job['cursor'] || -1
    next_cursor = next_cursor.to_i
    cursor = TwitterApi.service.friend_ids(streamer_tid, cursor: next_cursor)
    if (0 < cursor.next) # reque this job with the next page of results
      pull_streamer_friend_ids streamer_tid, cursor.next
    end
    friend_ids = cursor.ids.map &:to_s
    hover_crafts = HoverCraft.in twitter_id: friend_ids
    hover_craft_ids = hover_crafts.map &:twitter_id

    new_friend_ids = friend_ids - hover_craft_ids
    new_friend_ids = new_friend_ids.map &:to_i
    q_create_hover_crafts_for_streamer_friends new_friend_ids
  end

  # Process newfound friends of TweetStreamers to become new HoverCrafts
  # 1. Pull the twitter users (friends of a streamer)
  # 2. create a new HoverCrafts for each friend
  # 3. populate the HoverCraft with friend's twitter info
  def self.process_create_hover_crafts_for_streamer_friends(job)
    tids = job[:twitter_ids]
    users = TwitterApi.service.users(tid)
    users.each do |user_profile|
      params = hover_craft_info_for_twitter_user user_profile.to_hash
      hc = HoverCraft.where(twitter_id: params[:twitter_id]).first_or_create
      hc.update_attributes params
    end
  end

  def hover_craft_attributes_for(twitter_user_profile)
    twitter_profile = twitter_user_profile.slice *twitter_profile_attributes
    {
      twitter_id:           twitter_profile[:id_str],
      twitter_name:         twitter_profile[:name],
      twitter_screen_name:  twitter_profile[:screen_name],
      twitter_website:      twitter_profile[:url],
      twitter_profile:      twitter_profile,
    }
  end

  def twitter_profile_attributes
    [
      :id_str,
      :screen_name,
      :name,
      :description,
      :url,
      :followers_count,
      :friends_count,
      :statuses_count,
      :location,
      :lang,
      :created_at,
      :listed_count,
      :geo_enabled,
      :profile_image_url,
      :profile_image_url_https,
      :profile_background_image_url,
      :profile_background_image_url_https,
      :profile_background_tile,
      :profile_background_color,
      :profile_use_background_image,
      :default_profile,
      :default_profile_image,
      :profile_link_color,
      :profile_text_color,
      :profile_sidebar_border_color,
      :profile_sidebar_fill_color,
    ]
  end
end

