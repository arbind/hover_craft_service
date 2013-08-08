class TwitterApi::TwitterProfile < HashObject
  def to_hover_craft
    {
      twitter_id:           id_str,
      twitter_name:         name,
      twitter_screen_name:  screen_name,
      twitter_website_url:  url,
      twitter_profile:      to_profile
    }
  end

private

  def to_profile
    to_hash.select {|k,v| twitter_profile_attributes include? k.to_sym}
  end

  def self.twitter_profile_attributes
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

end
