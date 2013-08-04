class WorkerRefreshStreamers
  include Sidekiq::Worker
  include Sidekiq::ScheduledWorker
  @perform_after = ENV["TWEET_STREAMER_REFRESH_INTERVAL"]
  sidekiq_options :queue => :WorkerRefreshStreamers, :retry => false, :backtrace => true

  def perform
    TweetStreamer.each { |s| WorkerDetectNewStreamerFriends.schedule s.id }
    log
  end

private

  def log(info={})
    msg = "Scheduled refresh of #{TweetStreamer.count} Streamers"
    Rails.logger.info msg
  end
end