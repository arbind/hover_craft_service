class TwitterApi # via http://sferik.github.io/twitter/
  INVALID_IDS = {} # move this into redis as it gets bigger

  def self.service() self end

  def self.valid_id?(twitter_id)
    INVALID_IDS[twitter_id.to_i].nil?
  end

  def self.friend_ids(screen_name, options={})
    cursor = Twitter.friend_ids(screen_name, options)
  end

  def self.users(twitter_id_array, options={})
    return [] unless twitter_id_array and twitter_id_array.any?
    users_array = Twitter.users(twitter_id_array, options)
  rescue Twitter::Error::NotFound => not_found
    twitter_id_array.map {|id| INVALID_IDS[id] = :bad }
    []
  end

  def self.user(screen_name, options={})
    return nil unless screen_name
    user = Twitter.user(screen_name, options)
  end

  def self.friends(screen_name, options={})
    cursor = Twitter.friends(screen_name, options)
  end

end