class PopulateFromStreamerFriends < WorkerBase
  @perform_after = INTERVAL_FOR_TWITTER_RATE_LIMITS[:users]

  def self.work_data(streamer, friend_ids)
    {
      "streamer_id" => streamer.id.to_s,
      "friend_ids"  => friend_ids
    }
  end
end