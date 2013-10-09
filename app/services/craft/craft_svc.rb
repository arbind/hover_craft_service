class CraftSvc

  def self.materialize(craft)
    response = RestClient.post materialize_craft_url, craft: craft
    craft_from_response response
  rescue => ex
    puts "!!Fail: Can not materialize craft to #{materialize_craft_url}"
    raise ex
  end

  private

  def self.craft_from_response(response)
    return HashObject.new if response.blank?
    response_hash = JSON.parse response
    craft = response_hash['data']
    HashObject.new craft
  end

  def self.materialize_craft_url
    "#{CRAFT_SERVICE_ENDPOINT}/materialize"
  end
end