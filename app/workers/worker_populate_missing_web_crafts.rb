class WorkerPopulateMissingWebCrafts
  include Sidekiq::Worker
  include Sidekiq::ScheduledWorker
  @perform_after = 5.minutes

  def self.work_data(hover_craft_id)
    {
      "hover_craft_id" => hover_craft_id
    }
  end

  def perform
    HoverCraft.with_missing_web_craft.each do |hc|
      job_data = WorkerFindWebCrafts.work_data hc.id
      WorkerFindWebCrafts.schedule job_data
    end
    log
  end

private

  def log(info={})
    count = HoverCraft.with_missing_web_craft
    msg = "scheduled workers to FindWebCrafts for #{count} hover crafts"
    Rails.logger.info msg
  end
end