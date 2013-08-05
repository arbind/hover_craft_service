class WorkerRefreshStreamers
  include Sidekiq::Worker
  include Sidekiq::ScheduledWorker
  @perform_after = ENV["TWEET_STREAMER_REFRESH_INTERVAL"] || 1

  def perform
    TweetStreamer.each do |s|
      job_data = WorkerDetectNewStreamerFriends.work_data s.id
      WorkerDetectNewStreamerFriends.schedule job_data
    end
    log
  end

private

  def log(info={})
    msg = "Scheduled refresh of #{TweetStreamer.count} Streamers"
    Rails.logger.info msg
  end
end