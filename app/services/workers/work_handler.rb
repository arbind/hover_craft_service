class WorkHandler

  def self.streamer_friends(nada={})
    TwitterHandler.streamer_friends
  end

  # detect new friends that have been added to a streamer
  # schedule a new HoverCraft to be created for each new friend
  def self.streamer_friends_new(data)
    page = data.fetch('page', -1).to_i
    streamer_id     = data.fetch('streamer_id', nil)
    streamer = TweetStreamer.find streamer_id

    TwitterHandler.streamer_friends_new streamer, page
  end

  # slice list of friend ids into batches of 100 (twitter limit)
  # schedule a new HoverCraft to be created for each new friend
  def self.streamer_friends_create(data)
    friend_ids = data.fetch 'friend_ids'
    streamer_id = data.fetch 'streamer_id'
    streamer = TweetStreamer.find streamer_id
    TwitterHandler.streamer_friends_create streamer, friend_ids
  end

  def self.twitter_craft_new(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    TwitterHandler.twitter_craft_new hover_craft
  end

  def self.twitter_craft_create(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    TwitterHandler.twitter_craft_create hover_craft
  end

  def self.missing_web_crafts(nada={})
    HoverCraftHandler.missing_web_crafts
  end

  # Find any webcrafts that are missing
  def self.missing_web_crafts_new(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    HoverCraftHandler.missing_web_crafts_new hover_craft
  end

  def self.resolve_url(data)
    url_attribute = data.fetch 'url_attribute'
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    HoverCraftHandler.resolve_url hover_craft, url_attribute
  end

  def self.website_links(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    WebsiteHandler.website_links hover_craft
  end

  def self.yelp_craft_new(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    YelpHandler.yelp_craft_new hover_craft
  end

  def self.yelp_craft_create(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    YelpHandler.yelp_craft_create hover_craft
  end

end