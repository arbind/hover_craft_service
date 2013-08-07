class WorkHandler

  def self.streamer_friends(data)
    TweetStreamer.each {|s| Schedule.launch :streamer_friends_new, s.id}
  end

  # detect new friends that have been added to a streamer
  # schedule a new HoverCraft to be created for each new friend
  def self.streamer_friends_new(data)
    streamer_id     = data.fetch('streamer_id', nil)
    page = data.fetch('page', -1).to_i

    streamer = TweetStreamer.find streamer_id
    cursor = TwitterApi.service.friend_ids(streamer.tid, cursor: page)
    new_friend_ids = detect_new_twitter_ids cursor.ids
    Schedule.Launch :streamer_friends_create, streamer.id, new_friend_ids

    if 0 < cursor.next # schedule a scan for the next page of friends
      Schedule.launch :streamer_friends_new, streamer.id, cursor.next
    end
  end

  # slice list of friend ids into batches of 100 (twitter limit)
  # schedule a new HoverCraft to be created for each new friend
  def self.streamer_friends_create(data)
    streamer_id = data.fetch 'streamer_id'
    friend_ids = data.fetch 'friend_ids'

    streamer = TweetStreamer.find streamer_id
    batches_of_ids = friend_ids.each_slice(batch_size).to_a
    ids = batches_of_ids.shift # fetch only 100 ids at a time

    twitter_profiles = TwitterApi.service.users ids
    hover_craft_ids = create_hover_crafts_for_twitter_profiles twitter_profiles, streamer

    hover_craft_ids.each do |hc_id|
      Schedule.launch :resolve_url, hc_id, :twitter_website_url
    end

    batches_of_ids.each do |ids|
      Schedule.launch :streamer_friends_create, streamer.id, ids
    end
  end

  def self.resolve_url(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    url_attribute = data.fetch 'url_attribute'

    hover_craft = HoverCraft.find hover_craft_id
    first_url = hover_craft[url_attribute]
    final_url = Web.final_location_of_url first_url

    return if final_url.nil? or "".eql? final_url or first_url.eql? final_url
    hover_craft[url_attribute] = final_url
    hover_craft.save
    Schedule.launch :find_missing_web_crafts, hover_craft_id
  end

  def self.missing_web_crafts(nada)
    HoverCraft.with_missing_web_craft.each do |hc|
      Schedule.launch :missing_web_crafts_new, hc.id
    end
  end

  # Find any webcrafts that are missing
  def self.missing_web_crafts_new(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    #
  end

  def yelp_craft_new(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    #
  end

  def yelp_craft_create(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    #
  end

  def twitter_craft_new(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    #
  end

  def twitter_craft_create(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    #
  end

private

  def detect_new_twitter_ids(ids)
    tids = TwitterApi.service.select_valid_ids ids
    existing_tids = []
    batches_of_tids = tids.each_slice(batch_size).to_a
    batches_of_tids.each do |batch_of_tids|
      existing_tids += HoverCraft.in(twitter_id: batch_of_tids).pluck(:twitter_id)
    end
    (tids - existing_tids)
  end

  def self.create_hover_crafts_for_twitter_profiles(twitter_profiles, streamer)
    hover_craft_ids = []
    twitter_profiles.map do |profile|
      hc = profile.to_hover_craft
      hc[:tweet_streamer] = streamer
      HoverCraft.where(twitter_id: hc[:twitter_id]).first_or_create
      hover_craft.update_attributes hc
      hover_craft_ids.push hover_craft.id
    end
    # log
    hover_craft_ids
  end

  def self.batch_size
    TWITTER_FETCH_USERS_BATCH_SIZE
  end

  def log(info)
    msg = "#{info[:hover_crafts]} HoverCrafs created!"
    Rails.logger.info msg
  end
end