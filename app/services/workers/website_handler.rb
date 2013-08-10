class WebsiteHandler

  def populate_website_craft(hover_craft)
  end

  # Find any webcrafts that are missing
  def self.website_scan_for_links(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    #
  end
end