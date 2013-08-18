class PopulateYelpCraft < WorkerBase
  @perform_after = INTERVAL_FOR_YELP_RATE_LIMIT

  def self.work_data(hover_craft)
    {
      "hover_craft_id" => hover_craft.id.to_s
    }
  end
end