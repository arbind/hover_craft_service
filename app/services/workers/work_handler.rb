class WorkHandler

  def self.populate_from_streamers(nada={})
    TwitterHandler.populate_from_streamers
  end

  # detect new friends that have been added to a streamer
  # schedule a new HoverCraft to be created for each new friend
  def self.populate_from_streamer(data)
    page = data.fetch('page', -1).to_i
    streamer_id     = data.fetch('streamer_id', nil)
    streamer = TweetStreamer.find streamer_id

    TwitterHandler.populate_from_streamer streamer, page
  end

  # slice list of friend ids into batches of 100 (twitter limit)
  # schedule a new HoverCraft to be created for each new friend
  def self.populate_from_streamer_friends(data)
    friend_ids = data.fetch 'friend_ids'
    streamer_id = data.fetch 'streamer_id'
    streamer = TweetStreamer.find streamer_id
    TwitterHandler.populate_from_streamer_friends streamer, friend_ids
  end

  def self.populate_hover_crafts(nada={})
    HoverCraftHandler.populate_hover_crafts
  end

  # Find any webcrafts that are missing
  def self.populate_hover_craft(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    HoverCraftHandler.populate_hover_craft hover_craft
  end

  def self.populate_twitter_craft(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    TwitterHandler.populate_twitter_craft hover_craft
  end

  def self.populate_yelp_craft(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    YelpHandler.populate_yelp_craft hover_craft
  end

  def self.populate_website_craft(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    WebsiteHandler.populate_website_craft hover_craft
  end

  def self.populate_facebook_craft(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    FacebookHandler.populate_facebook_craft hover_craft
  end

  def self.hover_craft_resolve_url(data)
    url_attribute = data.fetch 'url_attribute'
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    HoverCraftHandler.hover_craft_resolve_url hover_craft, url_attribute
  end

  def self.website_scan_for_links(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    WebsiteHandler.website_scan_for_links hover_craft
  end

  def self.yelp_scan_for_link(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    YelpHandler.yelp_scan_for_link hover_craft
  end

end