class TwitterApi # via http://sferik.github.io/twitter/
  INVALID_IDS = {} # move this into redis as it gets bigger

  def self.service() self end

  def self.valid_id?(twitter_id)
    INVALID_IDS[twitter_id.to_i].nil?
  end

  def self.friend_ids(tid, options={})
    cursor = Twitter.friend_ids(tid, options)
  end

  def self.select_valid_friend_ids(friend_ids)
    valid_friend_ids = friend_ids.select{ |id| valid_id?(id) }
    valid_friend_ids.map! &:to_s
  end

  def self.users(ids, options={})
    tids = ids.map(&:to_i)
    users_array = Twitter.users(tids, options)
    users_array.map {|u| TwitterProfile.new u.to_hash }
  rescue Twitter::Error::NotFound => not_found
    tids.map {|id| INVALID_IDS[id] = :bad }
    []
  end

  def self.user(screen_name, options={})
    return nil unless screen_name
    user = Twitter.user(screen_name, options)
    TwitterProfile.new u.to_hash
  end

  def self.friends(screen_name, options={})
    cursor = Twitter.friends(screen_name, options)
  end

end