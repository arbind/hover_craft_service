class CraftSvc

  def self.materialize(craft)
    if craft[:id]
      updated_craft = update craft
    else
      updated_craft = create craft
    end
    updated_craft
  end

  private

  def self.create(craft)
    url = create_craft_url
    response = RestClient.post url, craft: craft
    craft_from_response response
  end

  def self.update(craft)
    url = update_craft_url craft[:id]
    response =  RestClient.patch url, craft: craft
    craft_from_response response
  end

  def self.craft_from_response(response)
    return HashObject.new if response.blank?
    response_hash = JSON.parse response
    craft = response_hash['data']
    HashObject.new craft
  end

  def self.create_craft_url
    "#{CRAFT_SERVICE_ENDPOINT}/crafts"
  end
  def self.update_craft_url(craft_id)
    "#{CRAFT_SERVICE_ENDPOINT}/crafts/#{craft_id}"
  end

end