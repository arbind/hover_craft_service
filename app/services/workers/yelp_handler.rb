class YelpHandler

  def self.populate_yelp_craft(hover_craft)
    return if hover_craft.yelp_crafted or hover_craft.yelp_name
    biz = nil
    if hover_craft.yelp_href and !hover_craft.yelp_id
      biz = biz_for_yelp_href hover_craft.yelp_href
    elsif hover_craft.website_profile and hover_craft.website_profile['yelp_links'].present?
      yelp_href = hover_craft.website_profile['yelp_links'].first
      biz = biz_for_yelp_href yelp_href
    elsif hover_craft.twitter_name and hover_craft.tweet_streamer.present?
      biz = biz_for_twitter_craft hover_craft
    elsif :yelp.eql? Web.provider_for_href hover_craft.twitter_website_url
      yelp_href = hover_craft.twitter_website_url
      biz = biz_for_yelp_href yelp_href
    elsif :yelp.eql? Web.provider_for_href hover_craft.facebook_website_url
      yelp_href = hover_craft.facebook_website_url
      biz = biz_for_yelp_href yelp_href
    end
    if biz
      hover_craft.update_attributes(biz.to_hover_craft)
      WorkLauncher.launch :yelp_scan_for_link, hover_craft
    end
  end

  def self.yelp_scan_for_link(hover_craft)
    return if hover_craft.yelp_website_url or !hover_craft.yelp_href
    yelp_id = YelpApi.yelp_id_from_href hover_craft.yelp_href
    yelp_website_url = YelpApi.website_for_id yelp_id
    hover_craft.update_attributes yelp_website_url: yelp_website_url
    HoverCraft.service.resolve_url hover_craft, :yelp_website_url
    WorkLauncher.launch :populate_hover_craft, hover_craft
  end

private
  def self.biz_for_yelp_href (href)
    YelpApi.biz_for_yelp_href href
  end

  def self.biz_for_twitter_craft(hover_craft)
    YelpApi.biz_for_name hover_craft.twitter_name, hover_craft.tweet_streamer.address
  end

end