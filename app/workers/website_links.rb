class WebsiteLinks < WorkerBase
  @perform_after = 1

  def self.work_data(hover_craft)
    {
      "hover_craft_id" => hover_craft.id.to_s
    }
  end
end
