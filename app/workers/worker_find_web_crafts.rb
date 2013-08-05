class WorkerFindWebCrafts
  include Sidekiq::Worker
  include Sidekiq::ScheduledWorker
  @perform_after = 1

  def self.work_data(hover_craft_id)
    {
      "hover_craft_id" => hover_craft_id.to_s
    }
  end

  def perform(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    hover_craft = HoverCraft.find hover_craft_id
  end

private

  def log(info={})
    msg = "Finding webcrafts for hover craft [#{info[hover_craft_id]}]"
    Rails.logger.info msg
  end
end