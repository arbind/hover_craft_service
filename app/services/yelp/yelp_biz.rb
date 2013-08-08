class YelpApi::YelpBiz < HashObject
  def to_hover_craft
    {
      yelp_id:          id,
      yelp_name:        name,
      yelp_href:        url,
      yelp_website_url: find_website_url,
      yelp_address:     construct_address,
      yelp_categories:  categories,
    }
  end

  def find_website_url
    return @website_url if @website_url
    biz_url = Web.site(url).select_first('#bizUrl a')
    return "" unless biz_url
    @website_url = biz_url.content if biz_url
    doc_links = []
    doc = Nokogiri::HTML(open url,  'User-Agent' => 'ruby')
    doc.css('#bizUrl a').each { |link| doc_links << link.content }
    @website_url = doc_links.first
  end

  def construct_address
    return nil unless location
    display_address_tokens = location["display_address"]
    return nil unless display_address_tokens and display_address_tokens.any?
    display_address_tokens.join(", ")
  end
end
