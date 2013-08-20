class WebsiteHandler

  def self.populate_website_craft(hover_craft)
    website_url = identify_website_url hover_craft
    website_craft = WebsiteApi.website_info website_url
    if website_craft
      hover_craft.update_attributes(website_craft.to_hover_craft)
      WorkLauncher.launch :populate_hover_craft, hover_craft if hover_craft.web_craft_missing?
    end

  end

  private

  def self.identify_website_url(hover_craft)
    candidate_urls = []
    if hover_craft.twitter_website_url and hover_craft.twitter_name and hover_craft.tweet_streamer.present?
      candidate_urls <<  hover_craft.twitter_website_url
    elsif hover_craft.twitter_website_url and hover_craft.twitter_name
      candidate_urls <<  hover_craft.twitter_website_url
    end
    candidate_urls.reject!{ |url| url.nil? or Web.provider_href? url }
    candidate_urls.first
  end
end