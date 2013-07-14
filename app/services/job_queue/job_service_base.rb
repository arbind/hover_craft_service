# assumes all friends of a TweetStreamer are verified TwitterCrafts
class JobServiceBase
  def self.service
    self
  end

  def self.process_next_job(key)
    entry = JobQueue.dequeue key
    process entry if entry
  end

private
  def self.process(entry)
    method ="process_#{entry.key}".to_sym
    send method, entry.job
  end
end

