class WorkerDetectNewStreamerFriends
  include Sidekiq::Worker
  include Sidekiq::ScheduledWorker
  @perform_after = INTERVAL_FOR_TWITTER_RATE_LIMITS[:friend_ids]
  sidekiq_options :queue => :WorkerDetectNewStreamerFriends, :retry => false, :backtrace => true

  def perform(streamer_id, cursor_position=-1)
    friend_ids = detect_new_streamer_friends streamer_id, cursor_position.to_i
    create_hover_crafts_for_new_streamer_friends streamer_id, friend_ids
  end

private
  def detect_new_streamer_friends(streamer_id, cursor_position)
    streamer = TweetStreamer.find streamer_id
    cursor = TwitterApi.service.friend_ids(streamer.tid, cursor: cursor_position)
    schedule_next_page streamer, cursor
    new_friend_ids = detect_new_friends cursor
    log({
      streamer: streamer.screen_name,
      new_friends: new_friend_ids.count,
      total_friends: cursor.ids.count
    })
    new_friend_ids
  end

  def create_hover_crafts_for_new_streamer_friends(streamer_id, friend_ids)
    batches_of_ids = friend_ids.each_slice(batch_size).to_a
    batches_of_ids.each do |ids|
      WorkerCreateHoverCraftsForNewStreamerFriends.schedule streamer_id, ids
    end
  end

  def schedule_next_page(streamer, cursor)
    self.class.schedule(streamer.id, cursor.next) if 0 < cursor.next
  end

  def detect_new_friends(cursor)
    friend_tids = TwitterApi.service.select_valid_friend_ids cursor.ids
    hover_craft_tids = []
    batches_of_ids = friend_tids.each_slice(batch_size).to_a
    batches_of_ids.each do |batch_of_friend_ids|
      hover_craft_tids += HoverCraft.in(twitter_id: batch_of_friend_ids).pluck(:twitter_id)
    end
    (friend_tids - hover_craft_tids)
  end

  def batch_size
    TWITTER_FETCH_USERS_BATCH_SIZE
  end

  def log(info)
    msg = "#{info[:streamer]} has #{info[:new_friends]}/#{info[:total_friends]} new friends"
    Rails.logger.info msg
  end
end