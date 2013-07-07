# assumes all friends of a TweetStreamer are verified TwitterCrafts
class TwitterJobs
  def service
    self
  end

  def self.process_next_job(key)
    job = JobQueue.dequeue key
    process job
  end

  def self.refresh_all_tweet_streamers
    TweetStreamer.all.each do |tweet_streamer|
      queue_tweet_streamer tweet_streamer
    end
  end

  def self.refresh_tweet_streamer(tweet_streamer)
    q_tweet_streamer_job tweet_streamer.twitter_id
  end

private

  def self.q_tweet_streamer_job(twitter_id, cursor = -1)
    key   = :tweet_streamer
    uid   = twitter_id
    job   = { twitter_id: twitter_id, cursor: cursor }
    group = :twitter
    JobQueue.enqueue(key, uid, job, group)
  end

  def self.q_twitter_craft_job(twitter_id)
    key   = :twitter_craft
    uid   = twitter_id
    job   = { twitter_id: twitter_id }
    group = :twitter
    JobQueue.enqueue(key, uid, job, group)
  end

  def self.process(job)
    method ="process_#{job[:key]}".to_sym
    send method, job
  end

  # Job Processors

  def self.process_tweet_streamer(job)
    tid = job[:twitter_id]
    next_cursor = job[:cursor]
    cursor = TwitterApi.service.friend_ids(tid, cursor: next_cursor)
    if (0 < cursor.next) # reque this job with the next page of results
      q_tweet_streamer_job tid, cursor.next
    end
    friend_ids = cursor.ids
    friend_ids.each do |fid|
      p 'q_twitter_craft_job id'
      # next if a hovercraft with twitter_id exists
      # next if the uid=twitter_id is found in the queue
      # q_twitter_craft_job id
    end
  end

  def self.process_twitter_craft(job)
    tid = job[:twitter_id]
    user = TwitterApi.service.user(tid)
    p 'HoverCraft.create params'
    # next if a hovercraft with twitter_id exists
    # params = hover_craft_for_twitter_user user
    # HoverCraft.create params
  end

end