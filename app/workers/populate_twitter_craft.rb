class PopulateTwitterCraft < WorkerBase
  @perform_after = INTERVAL_FOR_TWITTER_RATE_LIMITS[:user]

  def self.work_data(hover_craft)
    {
      "hover_craft_id" => hover_craft.id.to_s
    }
  end
end