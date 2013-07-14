class HoverCraft
  include Mongoid::Document
  include Mongoid::Timestamps

  field :craft_id
  field :tweet_streamer_id

  field :twitter_id
  field :twitter_name
  field :twitter_screen_name
  field :twitter_website_url
  field :twitter_address
  field :twitter_profile      , type: Hash
  field :twitter_craft        , type: Boolean, default: false

  field :yelp_id
  field :yelp_name
  field :yelp_href
  field :yelp_website_url
  field :yelp_address
  field :yelp_categories
  field :yelp_profile         , type: Hash
  field :yelp_craft           , type: Boolean, default: false

  field :facebook_id
  field :facebook_name
  field :facebook_href
  field :facebook_website_url
  field :facebook_address
  field :facebook_profile     , type: Hash
  field :facebook_craft       , type: Boolean, default: false

  field :website_url
  field :website_name
  field :website_profile      , type: Hash
  field :website_craft        , type: Boolean, default: false

  scope :with_yelp_craft,     exists(yelp_id: true)
  scope :with_twitter_craft,  exists(twitter_id: true)
  scope :with_website_craft,  exists(website_id: true)
  scope :with_facebook_craft, exists(facebook_id: true)
  scope :with_tweet_streamer, exists(tweet_streamer_id: true)

  scope :without_yelp_craft,     exists(yelp_id: false)
  scope :without_twitter_craft,  exists(twitter_id: false)
  scope :without_website_craft,  exists(website_id: false)
  scope :without_facebook_craft, exists(facebook_id: false)
  scope :without_tweet_streamer, exists(tweet_streamer_id: false)

  def tweet_streamer
    TweetStreamer.where(id:tweet_streamer_id).first
  end

end