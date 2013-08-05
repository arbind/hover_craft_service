class WorkerScanWebsiteForLinks
  include Sidekiq::Worker
  include Sidekiq::ScheduledWorker
  @perform_after = 1

  def self.work_data(hover_craft_id)
    {
      "hover_craft_id" => hover_craft_id
    }
  end

  def perform(data)
  end

private

  def log(info={})
    msg = ""
    Rails.logger.info msg
  end
end
