class HoverCraftHandler

  def self.populate_hover_crafts(nada={})
    HoverCraft.with_missing_web_craft.each do |hc|
      WorkLauncher.launch :populate_hover_craft, hc
    end
  end

  def self.populate_hover_craft(hover_craft)
  end

  def self.hover_craft_resolve_url(hover_craft, url_attribute)
    first_url = hover_craft[url_attribute]
    final_url = Web.final_location_of_url first_url

    return if !final_url.present? or first_url.eql? final_url
    hover_craft[url_attribute] = final_url
    hover_craft.save
    WorkLauncher.launch :populate_hover_craft, hover_craft
  end

end