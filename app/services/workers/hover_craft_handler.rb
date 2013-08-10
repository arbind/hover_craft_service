class HoverCraftHandler

  def self.populate_hover_crafts(nada={})
    HoverCraft.with_missing_web_craft.each do |hc|
      WorkLauncher.launch :populate_hover_craft, hc
    end
  end

  def populate_hover_craft(hover_craft)
  end

  def self.hover_craft_resolve_url(data)
    url_attribute = data.fetch 'url_attribute'
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id

    first_url = hover_craft[url_attribute]
    final_url = Web.final_location_of_url first_url

    return if !final_url.present? or first_url.eql? final_url
    hover_craft[url_attribute] = final_url
    hover_craft.save
    WorkLauncher.launch :populate_website_craft, hover_craft
  end

end