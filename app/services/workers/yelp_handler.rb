class YelpHandler

  def self.populate_yelp_craft(hover_craft)
    return if hover_craft.yelp_craft or hover_craft.yelp_name
    biz = nil
    if hover_craft.twitter_name and hover_craft.tweet_streamer.present?
      biz = biz_for_twitter_craft hover_craft
    elsif hover_craft.yelp_href and !hover_craft.yelp_id
      biz = biz_for_yelp_href hover_craft.yelp_href
    end
    if biz
      hover_craft.update_attributes(biz.to_hover_craft)
      WorkLauncher.launch :yelp_scan_for_link, hover_craft
    end
#     return unless hover_craft.twitter_name and hover_craft.twitter_screen_name
#     tweet_streamer = hover_craft.tweet_streamer
#     place = tweet_streamer.address if tweet_streamer
#     place ||= hover_craft.twitter_address
#     return unless place

#     uid      = "yelp.for.#{hover_craft.twitter_screen_name}"
#     biz_name = hover_craft.twitter_name
#     job      = {hover_craft_id:hover_craft.id, biz_name: biz_name, place: place }
#     JobQueue.enqueue(key, uid, job, GROUP)

#     hover_craft_id = job.hover_craft_id
#     biz_name = job.biz_name
#     place = job.place
#     hover_craft = HoverCraft.where(id:hover_craft_id).first
#     return unless hover_craft
#     biz = YelpApi.service.biz_for_name(biz_name, place)
#     biz ||= HashObject.new({yelp_id: ""})
#     hover_craft.update_attributes biz.to_hover_craft
  end

  def self.yelp_scan_for_link(hover_craft)
    return if hover_craft.yelp_website_url or ! hover_craft.yelp_href
    biz_url = Web.site(hover_craft.yelp_href).select_first('#bizUrl a')
    return "" unless biz_url
    hover_craft.yelp_website_url = biz_url.content if biz_url
    doc_links = []
    doc = Nokogiri::HTML(open hover_craft.yelp_href,  'User-Agent' => 'ruby')
    doc.css('#bizUrl a').each { |link| doc_links << link.content }
    hover_craft.yelp_website_url = doc_links.first
  end

private
  def self.biz_for_yelp_href (href)
    YelpApi.biz_for_yelp_href href
  end

  def self.biz_for_twitter_craft(hover_craft)
    YelpApi.biz_for_name hover_craft.twitter_name, hover_craft.tweet_streamer.address
  end

end