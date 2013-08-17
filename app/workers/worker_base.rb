class WorkerBase
  include Sidekiq::Worker
  include Sidekiq::ScheduledWorker

  def self.work_data(*args)
    {}
  end

  def perform(data={})
    handler = self.class.name.underscore.to_sym
    WorkHandler.send handler, data
  end
end