class ResolveUrl < WorkerBase
  @perform_after = 1

  def self.work_data(hover_craft_id, url_attribute='twitter_website_url')
    {
      "hover_craft_id" => hover_craft_id.to_s,
      "url_attribute"  => url_attribute
    }
  end
end