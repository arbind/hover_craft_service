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
  field :twitter_craft        , type: Boolean

  field :yelp_id
  field :yelp_name
  field :yelp_href
  field :yelp_website_url
  field :yelp_address
  field :yelp_categories
  field :yelp_profile         , type: Hash
  field :yelp_craft           , type: Boolean

  field :facebook_id
  field :facebook_name
  field :facebook_href
  field :facebook_website_url
  field :facebook_address
  field :facebook_profile     , type: Hash
  field :facebook_craft       , type: Boolean

  field :website_url
  field :website_name
  field :website_profile      , type: Hash
  field :website_craft        , type: Boolean

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

  # # score
  # field :fit_score          , type: Integer, default: FIT_check_manually
  # field :fit_score_name     , type: Integer, default: FIT_check_manually
  # field :fit_score_website  , type: Integer, default: FIT_check_manually
  # field :fit_score_username , type: Integer, default: FIT_check_manually
  # # field :fit_score_food, type: Integer, default: FIT_check_manually
  # # field :fit_score_mobile, type: Integer, default: FIT_check_manually

  # # Needs follow up for corrections
  # field :flag                 , type: Boolean

  # # manual overrides
  # field :skip_this_craft      , type: Boolean, default: false
  # field :approve_this_craft   , type: Boolean, default: false

  # # error states
  # field :error_duplicate_crafts, type: Boolean, default: false

  #  # scopes
  # scope :need_to_explore, where(fit_score: FIT_need_to_explore)
  # scope :check_manually,  where(fit_score: FIT_check_manually)
  # scope :missing_craft,   where(fit_score: FIT_missing_craft)
  # scope :zero_fit,        where(fit_score: FIT_zero)
  # scope :neutral_fit,     where(fit_score: FIT_neutral)
  # scope :absolute_fit,    where(fit_score: FIT_absolute)