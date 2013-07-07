# assumes all friends of a TweetStreamer are verified TwitterCrafts
class TwitterJobs
  def service
    self
  end

  def self.process_next_job(key)
    p 'processing', key
    entry = JobQueue.dequeue key
    p 'processing', entry
    process entry if entry
  end

  def self.refresh_all_tweet_streamers
    TweetStreamer.all.each do |tweet_streamer|
      refresh_tweet_streamer tweet_streamer
    end
  end

  def self.refresh_tweet_streamer(tweet_streamer)
    pull_streamer_friend_ids tweet_streamer.screen_name
  end

private

  # Queue job to find any new TweetStreamer friends
  def self.pull_streamer_friend_ids(screen_name, cursor = -1)
    p 34, screen_name
    p "pull_streamer_friend_ids: #{screen_name}"
    key = :pull_streamer_friend_ids
    return unless screen_name
    group = :twitter
    uid   = screen_name
    job   = { screen_name: screen_name, cursor: cursor }
    p "pull_streamer_friend_ids: #{job}"
    JobQueue.enqueue(key, uid, job, group)
  end

  # Queue newfound friends of TweetStreamers to become new HoverCrafts
  def self.q_create_hover_crafts_for_streamer_friends(twitter_ids)
    key   = :create_hover_crafts_for_streamer_friends
    return unless twitter_ids and twitter_ids.any?
    group = :twitter
    uid   = twitter_ids.first

    batch_of_100_ids = twitter_ids.each_slice(100).to_a
    batch_of_100_ids.each do |ids_for_100_friends|
      job   = { twitter_ids: ids_for_100_friends }
      JobQueue.enqueue(key, uid, job, group)
    end
  end

  def self.process(entry)
    method ="process_#{entry[:key]}".to_sym
    p 'processing', method
    send method, entry[:job]
  end

  # Job Processors

  # Process job to find any new TweetStreamer friends
  # 1. Pull friends ids from TweetStreamer
  # 2. detect new friends
  # 3. queue newfound friends to become a HoverCraft
  def self.process_pull_streamer_friend_ids(job)
    streamer_tid = job['screen_name']
    next_cursor = job['cursor'] || -1
    next_cursor = next_cursor.to_i
    cursor = TwitterApi.service.friend_ids(streamer_tid, cursor: next_cursor)
    if (0 < cursor.next) # reque this job with the next page of results
      pull_streamer_friend_ids streamer_tid, cursor.next
    end
    p cursor
    friend_ids = cursor.ids.map &:to_s
    hover_crafts = HoverCraft.in twitter_id: friend_ids
    hover_craft_ids = hover_crafts.map &:twitter_id

    new_friend_ids = friend_ids - hover_craft_ids
    new_friend_ids = new_friend_ids.map &:to_i
    q_create_hover_crafts_for_streamer_friends new_friend_ids
  end

  # Process newfound friends of TweetStreamers to become new HoverCrafts
  # 1. Pull the twitter users (friends of a streamer)
  # 2. create a new HoverCrafts for each friend
  # 3. populate the HoverCraft with friend's twitter info
  def self.process_create_hover_crafts_for_streamer_friends(job)
    tids = job[:twitter_ids]
    users = TwitterApi.service.users(tid)
    p 'users'
    p users
    users.each do |user|
      params = hover_craft_info_for_twitter_user
      hc = HoverCraft.where(twitter_id: params[:twitter_id]).first_or_create
      hc.update_attributes params
    end
  end
end