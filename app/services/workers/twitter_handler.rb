class TwitterHandler

  def self.populate_twitter_craft(hover_craft)
    #elsif any [provider]_website_url points to a twitter_href
    #  twitter_href = [provider]_website_url
    #  populate from twitter_href
    # if twitter_craft was populated, and there are still missing webcrafts, schedule a populate_hover_craft
  end

  def self.populate_from_streamers
    TweetStreamer.each {|streamer| WorkLauncher.launch :populate_from_streamer, streamer}
  end

  # detect new friends that have been added to a streamer
  # schedule a new HoverCraft to be created for each new friend
  def self.populate_from_streamer(streamer, page=-1)
    cursor = TwitterApi.service.friend_ids(streamer.tid, cursor: page)
    new_friend_ids = detect_new_twitter_ids cursor.ids

    batches_of_ids = new_friend_ids.each_slice(batch_size).to_a

    batches_of_ids.each do |ids|
      WorkLauncher.launch :populate_from_streamer_friends, streamer, ids
    end

    if 0 < cursor.next # schedule a scan for the next page of friends
      WorkLauncher.launch :populate_from_streamer, streamer, cursor.next
    end
  end

  # slice list of friend ids into batches of 100 (twitter limit)
  # schedule a new HoverCraft to be created for each new friend
  def self.populate_from_streamer_friends(streamer, friend_ids)
    batches_of_ids = friend_ids.each_slice(batch_size).to_a
    ids = batches_of_ids.shift # fetch only 100 ids at a time

    twitter_profiles = TwitterApi.service.users ids
    hover_crafts = create_hover_crafts_for_twitter_profiles twitter_profiles, streamer

    hover_crafts.each do |hover_craft|
      WorkLauncher.launch :hover_craft_resolve_url, hover_craft, :twitter_website_url
    end

    batches_of_ids.each do |ids|
      WorkLauncher.launch :populate_from_streamer_friends, streamer, ids
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
    hover_crafts = []
    twitter_profiles.map do |profile|
      hc = profile.to_hover_craft
      hc[:tweet_streamer] = streamer
      hc[:craftable] = true # automatically promoted streamer friends to be craftable with a FIT_absolute twitter score
      hc[:twitter_fit_score] = HoverCraft::FIT_absolute
      hover_craft = HoverCraft.where(twitter_id: hc[:twitter_id]).first_or_create
      hover_craft.update_attributes hc
      hover_crafts.push hover_craft
    end
    # log
    hover_crafts
  end

  def self.batch_size
    TWITTER_FETCH_USERS_BATCH_SIZE
  end

end