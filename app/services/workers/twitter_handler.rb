class TwitterHandler

  def twitter_craft_new(hover_craft)
  end

  def twitter_craft_create(hover_craft)
  end

  def self.streamer_friends
    TweetStreamer.each {|streamer| WorkLauncher.launch :streamer_friends_new, streamer}
  end

  # detect new friends that have been added to a streamer
  # schedule a new HoverCraft to be created for each new friend
  def self.streamer_friends_new(streamer, page=-1)
    cursor = TwitterApi.service.friend_ids(streamer.tid, cursor: page)
    new_friend_ids = detect_new_twitter_ids cursor.ids

    batches_of_ids = new_friend_ids.each_slice(batch_size).to_a

    batches_of_ids.each do |ids|
      WorkLauncher.launch :streamer_friends_create, streamer, ids
    end

    if 0 < cursor.next # schedule a scan for the next page of friends
      WorkLauncher.launch :streamer_friends_new, streamer, cursor.next
    end
  end

  # slice list of friend ids into batches of 100 (twitter limit)
  # schedule a new HoverCraft to be created for each new friend
  def self.streamer_friends_create(streamer, friend_ids)
    batches_of_ids = friend_ids.each_slice(batch_size).to_a
    ids = batches_of_ids.shift # fetch only 100 ids at a time

    twitter_profiles = TwitterApi.service.users ids
    hover_crafts = create_hover_crafts_for_twitter_profiles twitter_profiles, streamer

    hover_crafts.each do |hover_craft|
      WorkLauncher.launch :resolve_url, hover_craft, :twitter_website_url
    end

    batches_of_ids.each do |ids|
      WorkLauncher.launch :streamer_friends_create, streamer, ids
    end
  end

private

  def self.detect_new_twitter_ids(ids)
    tids = TwitterApi.service.select_valid_ids ids
    existing_tids = []
    batches_of_tids = tids.each_slice(batch_size).to_a
    batches_of_tids.each do |batch_of_tids|
      existing_tids += HoverCraft.in(twitter_id: batch_of_tids).pluck(:twitter_id)
    end
    (tids - existing_tids)
  end

  def self.create_hover_crafts_for_twitter_profiles(twitter_profiles, streamer)
    hover_craft = []
    twitter_profiles.map do |profile|
      hc = profile.to_hover_craft
      hc[:tweet_streamer] = streamer
      HoverCraft.where(twitter_id: hc[:twitter_id]).first_or_create
      hover_craft.update_attributes hc
      hover_craft.push hover_craft
    end
    # log
    hover_craft
  end

  def self.batch_size
    TWITTER_FETCH_USERS_BATCH_SIZE
  end

end