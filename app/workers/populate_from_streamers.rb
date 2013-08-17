class PopulateFromStreamers < WorkerBase
  @perform_after = ENV["TWEET_STREAMER_REFRESH_INTERVAL"] || 1
end