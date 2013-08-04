class WorkerCreateHoverCraftsForNewStreamerFriends

  include Sidekiq::Worker
  include Sidekiq::ScheduledWorker
  @perform_after = INTERVAL_FOR_TWITTER_RATE_LIMITS[:users]
  sidekiq_options :queue => :WorkerCreateHoverCraftsForNewStreamerFriends, :retry => false, :backtrace => true

  def perform(streamer_id, friend_ids)
  end
end