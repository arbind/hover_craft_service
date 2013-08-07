class Schedule

  def self.launch(worker, *args)
    launch_worker worker, *args
  end

private
  def self.launch_worker(m, *args)
    worker_klazz = m.to_s.camelcase.constantize
    data = worker_klazz.work_data *args
    worker_klazz.schedule data
  end
end
