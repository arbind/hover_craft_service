class TwitterApi # via http://sferik.github.io/twitter/

  def self.service
    self
  end

  def self.user(screen_name, options)
    tid = id_for(twitter_id)
    user = Twitter.user(tid, options)
  end

  def self.friends(twitter_id, options={})
    tid = id_for(twitter_id)
    cursor = Twitter.friends(tid, options)
  end

  def self.friend_ids(twitter_id, options={})
    tid = id_for(twitter_id)
    cursor = Twitter.friend_ids(tid, options)
  end

private

  def id_for(twitter_id)
    id = twitter_id.to_i
    id = twitter_id if 0 == id
  end

end