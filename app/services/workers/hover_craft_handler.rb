class HoverCraftHandler

  def self.missing_web_crafts(nada)
    HoverCraft.with_missing_web_craft.each do |hc|
      WorkLauncher.launch :missing_web_crafts_new, hc.id
    end
  end

  # Find any webcrafts that are missing
  def self.missing_web_crafts_new(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
    #
  end

  def self.resolve_url(hover_craft, url_attribute)
    first_url = hover_craft[url_attribute]
    final_url = Web.final_location_of_url first_url

    return if final_url.nil? or "".eql? final_url or first_url.eql? final_url
    hover_craft[url_attribute] = final_url
    hover_craft.save
    WorkLauncher.launch :find_missing_web_crafts, hover_craft_id
  end

end