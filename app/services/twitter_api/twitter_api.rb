class TwitterApi # via http://sferik.github.io/twitter/

  def self.service
    self
  end

  def self.user(screen_name, options={})
    user = Twitter.user(screen_name, options)
  end

  def self.users(twitter_id_array, options={})
    user = Twitter.users(twitter_id_array, options)
  end

  def self.friends(screen_name, options={})
    cursor = Twitter.friends(screen_name, options)
  end

  def self.friend_ids(screen_name, options={})
    cursor = Twitter.friend_ids(screen_name, options)
  end

end