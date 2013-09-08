class WebsiteHandler

  def self.populate_website_craft(hover_craft)
    return if hover_craft.website_crafted or hover_craft.website_url
    website_url = identify_website_url hover_craft
    return if website_url.to_s.empty?
    website_craft = WebsiteApi.website_info website_url
    if website_craft
      hover_craft.update_attributes(website_craft.to_hover_craft)
      WorkLauncher.launch :populate_hover_craft, hover_craft
    end
  end

  private

  def self.identify_website_url(hover_craft)
    candidate_urls = []
    if hover_craft.twitter_website_url and hover_craft.twitter_name
      candidate_urls <<  hover_craft.twitter_website_url
    elsif hover_craft.facebook_website_url
      candidate_urls <<  hover_craft.facebook_website_url
    elsif hover_craft.yelp_website_url
      candidate_urls <<  hover_craft.yelp_website_url
      candidate_urls <<  hover_craft.twitter_website_url
    end
    candidate_urls.reject!{ |url| url.nil? or Web.provider_href? url }
    candidate_urls.first
  end
end