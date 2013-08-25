class HoverCraftResolveUrl < WorkerBase
  @perform_after = 1.second

  def self.work_data(hover_craft, url_attribute=:twitter_website_url)
    {
      "hover_craft_id" => hover_craft.id.to_s,
      "url_attribute"  => url_attribute.to_sym
    }
  end
end