class WorkLauncher

  def self.launch(worker, *args)
    launch_worker worker, *args
  end

  def self.launch_after_waiting(duration_to_wait, worker, *args)
    launch_worker_after_waiting duration_to_wait, worker, *args
  end

private
  def self.launch_worker(m, *args)
    worker_klazz = m.to_s.camelcase.constantize
    data = worker_klazz.work_data *args
    worker_klazz.schedule data
  end

  def self.launch_worker_after_waiting (duration_to_wait, m, *args)
    worker_klazz = m.to_s.camelcase.constantize
    data = worker_klazz.work_data *args
    worker_klazz.delay_schedule_until duration_to_wait, data
  end
end