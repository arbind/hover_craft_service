class TwitterCraftNew < WorkerBase
  @perform_after = 1000000

  def self.work_data(hover_craft_id)
    {
      "hover_craft_id" => hover_craft_id.to_s
    }
  end
end