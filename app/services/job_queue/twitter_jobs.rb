# assumes all friends of a TweetStreamer are verified TwitterCrafts
class TwitterJobs < JobServiceBase
  GROUP = :twitter
  def self.pull_twitter_crafts_from_all_streamers
    TweetStreamer.all.each do |tweet_streamer|
      pull_twitter_crafts_from_streamer tweet_streamer
    end
  end

  def self.pull_twitter_crafts_from_streamer(tweet_streamer)
    q_pull_streamer_friend_ids tweet_streamer
  end

private

  # Queue job to find any new TweetStreamer friends
  def self.q_pull_streamer_friend_ids(tweet_streamer, cursor = -1)
    key = :pull_streamer_friend_ids
    return unless tweet_streamer and tweet_streamer.screen_name
    uid   = tweet_streamer.screen_name
    job   = {
      streamer_id: tweet_streamer.id,
      cursor: cursor
    }
    JobQueue.enqueue(key, uid, job, GROUP)
  end

  # Queue newfound friends of TweetStreamers to become new HoverCrafts
  def self.q_create_hover_crafts_for_streamer_friends(twitter_ids, streamer_id)
    key   = :create_hover_crafts_for_streamer_friends
    return unless twitter_ids and twitter_ids.any?

    batch_size = 100
    batches_of_ids = twitter_ids.each_slice(batch_size).to_a
    batches_of_ids.each do |batch_of_friend_ids|
      uid   = batch_of_friend_ids.first
      job   = { twitter_ids: batch_of_friend_ids, streamer_id: streamer_id }
      JobQueue.enqueue(key, uid, job, GROUP)
    end
  end

  # Job Processors

  # Process job to find any new TweetStreamer friends
  # 1. Pull friends ids from TweetStreamer
  # 2. detect new friends
  # 3. queue newfound friends to become a HoverCraft
  def self.process_pull_streamer_friend_ids(job)
    streamer_id = job.streamer_id
    streamer = TweetStreamer.where(id:streamer_id).first
    return unless streamer
    next_cursor = job.cursor || -1
    next_cursor = next_cursor.to_i
    cursor = TwitterApi.service.friend_ids(streamer.screen_name, cursor: next_cursor)
    if (0 < cursor.next) # reque this job with the next page of results
      q_pull_streamer_friend_ids streamer.screen_name, cursor.next
    end
    friend_ids = cursor.ids.select{ |id| TwitterApi.service.valid_id?(id) }
    friend_ids = friend_ids.map! &:to_s

    hover_craft_ids = []
    batch_size = 100
    batches_of_ids = friend_ids .each_slice(batch_size).to_a
    batches_of_ids.each do |batch_of_friend_ids|
      hover_crafts = HoverCraft.in twitter_id: batch_of_friend_ids
      hover_craft_ids += hover_crafts.map &:twitter_id
    end
    new_friend_ids = friend_ids - hover_craft_ids
    new_friend_ids = new_friend_ids.map &:to_i

    msg =  "#{streamer.screen_name} has #{new_friend_ids.count} new friends "
    msg += "( #{friend_ids.count} total )"
    puts msg

    q_create_hover_crafts_for_streamer_friends new_friend_ids, streamer_id
  end

  # Process newfound friends of TweetStreamers to become new HoverCrafts
  # 1. Pull the twitter users (friends of a streamer)
  # 2. create a new HoverCrafts for each friend
  # 3. populate the HoverCraft with friend's twitter info
  def self.process_create_hover_crafts_for_streamer_friends(job)
    tids = job.twitter_ids
    streamer_id = job.streamer_id
    users = TwitterApi.service.users(tids)
    users.each do |user_profile|
      params = hover_craft_attributes_for user_profile
      params[:tweet_streamer_id] = streamer_id
      hover_craft = HoverCraft.where(twitter_id: params[:twitter_id]).first_or_create
      hover_craft.update_attributes params
      YelpJobs.service.pull_yelp_craft_for_new_twitter_craft hover_craft
    end
  end

  def self.hover_craft_attributes_for(twitter_user_profile)
    twitter_profile = twitter_user_profile.to_hash
    twitter_profile.slice! *twitter_profile_attributes
    {
      twitter_id:           twitter_profile[:id_str],
      twitter_name:         twitter_profile[:name],
      twitter_screen_name:  twitter_profile[:screen_name],
      twitter_website_url:  twitter_profile[:url],
      twitter_profile:      twitter_profile,
    }
  end

  def self.twitter_profile_attributes
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

