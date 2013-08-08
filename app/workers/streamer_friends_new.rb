class StreamerFriendsNew < WorkerBase
  @perform_after = INTERVAL_FOR_TWITTER_RATE_LIMITS[:friend_ids]

  def self.work_data(streamer, page=-1)
    {
      "streamer_id" => streamer.id.to_s,
      "page"        => page
    }
  end
end