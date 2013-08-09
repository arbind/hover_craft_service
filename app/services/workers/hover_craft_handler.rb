class HoverCraftHandler

  def self.missing_web_crafts(nada={})
    HoverCraft.with_missing_web_craft.each do |hc|
      WorkLauncher.launch :missing_web_crafts_new, hc
    end
  end

  # Find any webcrafts that are missing
  def self.missing_web_crafts_new(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    #
  end

  def self.resolve_url(data)
    url_attribute = data.fetch 'url_attribute'
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id

    first_url = hover_craft[url_attribute]
    final_url = Web.final_location_of_url first_url

    return if !final_url.present? or first_url.eql? final_url
    hover_craft[url_attribute] = final_url
    hover_craft.save
    WorkLauncher.launch :missing_web_crafts, hover_craft
  end

end