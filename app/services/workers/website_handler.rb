class WebsiteHandler

  # Find any webcrafts that are missing
  def self.website_links(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    #
  end

end
