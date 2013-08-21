class TwitterApi # via http://sferik.github.io/twitter/
  INVALID_IDS = {} # move this into redis as it gets bigger

  def self.service() self end

  def self.valid_id?(twitter_id)
    INVALID_IDS[twitter_id.to_i].nil?
  end

  def self.friend_ids(tid, options={})
    cursor = Twitter.friend_ids(tid, options)
  end

  def self.select_valid_ids(friend_ids)
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

  # TwitterProfile
  # HashObject that makes it easy to work with responses from the Twitter gem
  class TwitterProfile < HashObject
    def initialize(hash)
      super
      self.url = self.url.strip.to_href if self.url
    end
    def to_hover_craft
      {
        twitter_id:           id_str,
        twitter_name:         name,
        twitter_screen_name:  screen_name,
        twitter_website_url:  url,
        twitter_profile:      to_profile
      }
    end

    def self.profile_attributes
      [
        :id_str,
        :screen_name,
        :name,
        :description,
        :url,
        :followers_count,
        :friends_count,
        :statuses_count,
        :location,
        :lang,
        :created_at,
        :listed_count,
        :geo_enabled,
        :profile_image_url,
        :profile_image_url_https,
        :profile_background_image_url,
        :profile_background_image_url_https,
        :profile_background_tile,
        :profile_background_color,
        :profile_use_background_image,
        :default_profile,
        :default_profile_image,
        :profile_link_color,
        :profile_text_color,
        :profile_sidebar_border_color,
        :profile_sidebar_fill_color,
      ]
    end
  private

    def to_profile
      to_hash.select {|k,v| TwitterProfile.profile_attributes.include? k.to_sym}
    end
  end

end