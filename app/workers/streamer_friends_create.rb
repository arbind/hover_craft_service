class StreamerFriendsCreate < WorkerBase
  @perform_after = INTERVAL_FOR_TWITTER_RATE_LIMITS[:users]

  def self.work_data(streamer_id, friend_ids)
    {
      "streamer_id" => streamer_id.to_s,
      "friend_ids"  => friend_ids
    }
  end
end