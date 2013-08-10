class PopulateHoverCraft < WorkerBase
  @perform_after = 5.minutes

  def self.work_data(hover_craft)
    {
      "hover_craft_id" => hover_craft.id.to_s
    }
  end
end