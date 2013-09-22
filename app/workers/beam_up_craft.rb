class BeamUpCraft < WorkerBase
  @perform_after = 1.second

  def self.work_data(hover_craft)
    {
      "hover_craft_id" => hover_craft.id.to_s
    }
  end

  def self.before_schedule(data)
    remove_existing_jobs data['hover_craft_id']
  end

  def self.remove_existing_jobs(hover_craft_id)
    Thread.exclusive do # 1 Sidekiq client connection at a time
      scheduled_jobs  = Sidekiq::ScheduledSet.new
      existing_beam_up_jobs = scheduled_jobs.select{|job| data = job.args.first; 'BeamUpCraft'.eql? job.queue and data and data.has_value? hover_craft_id }
      existing_beam_up_jobs.map &:delete
    end
  end
end