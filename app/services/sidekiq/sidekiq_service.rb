class SidekiqService

  def self.num_scheduled_jobs
    Sidekiq::ScheduledSet.new.count
  end

  def self.clear_scheduled_jobs
    Sidekiq::ScheduledSet.new.clear
  end

  def self.clear_all_stats
    clear_stats_for_processed
    clear_stats_for_failed
  end

  def self.clear_stats_for_processed
    clear_stats_for 'processed'
  end

  def self.clear_stats_for_failed
    clear_stats_for 'failed'
  end

  def self.clear_stats_for(category)
    Sidekiq.redis {|c| c.del("stat:#{category}") }
  end
end