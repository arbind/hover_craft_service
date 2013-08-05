class HoverCraft
  include Mongoid::Document
  include Mongoid::Timestamps

  # score constants
  FIT_duplicate_crafts = -2 # flagen 2               hover crafts bind to the same already existing craft
  FIT_need_to_explore = -1  # flag go               get hover crafts and explore this
  FIT_zero = 0              # its not a fit
  FIT_missing_craft = 1     # missing info
  FIT_check_manually = 3    # flagr ma              nual check
  FIT_neutral = 5           # at least its not a bad fit
  FIT_absolute = 8          # known to be a fit

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

  # manual overrides
  field :approve_this         , type: Boolean
  field :flag_this            , type: Boolean # Needs follow up for corrections
  field :skip_this            , type: Boolean

  field :fit_score            , type: Integer, default: FIT_check_manually
  field :fit_score_name       , type: Integer, default: FIT_check_manually
  field :fit_score_website    , type: Integer, default: FIT_check_manually
  field :fit_score_username   , type: Integer, default: FIT_check_manually
  # # field :fit_score_food, type: Integer, default: FIT_check_manually
  # # field :fit_score_mobile, type: Integer, default: FIT_check_manually

  scope :crafted          , exists(craft_id: true).desc(:fit_score)
  scope :uncrafted        , exists(craft_id: false).desc(:fit_score)

  scope :approved         , where(approve_this: true)
  scope :flagged          , where(flag_this: true)
  scope :skipped          , where(skip_this: true)
  scope :unapproved       , excludes(approve_this: true)
  scope :unflagged        , excludes(flag_this: true)
  scope :unskipped        , excludes(skip_this: true)

  scope :with_yelp        , exists(yelp_id: true)
  scope :with_twitter     , exists(twitter_id: true)
  scope :with_website     , exists(website_url: true)
  scope :with_facebook    , exists(facebook_id: true)
  scope :with_streamer    , exists(tweet_streamer_id: true)

  scope :without_yelp     , exists(yelp_id: false)
  scope :without_twitter  , exists(twitter_id: false)
  scope :without_website  , exists(website_url: false)
  scope :without_facebook , exists(facebook_id: false)
  scope :without_streamer , exists(tweet_streamer_id: false)

  # crafts with both twitter and yelp
  scope :twelps,  exists(yelp_id: true).exists(twitter_id: true).desc(:yelp_name)

  scope :with_missing_web_craft, any_of( {yelp_id: nil},
                                     {twitter_id: nil},
                                     {facebook_id: nil},
                                     {website_url: nil}
                                   ).desc(:yelp_name)

  # score scopes
  scope :need_to_explore, where(fit_score: FIT_need_to_explore)
  scope :check_manually,  where(fit_score: FIT_check_manually)
  scope :missing_craft,   where(fit_score: FIT_missing_craft)
  scope :zero_fit,        where(fit_score: FIT_zero)
  scope :neutral_fit,     where(fit_score: FIT_neutral)
  scope :absolute_fit,    where(fit_score: FIT_absolute)

  def tweet_streamer
    TweetStreamer.where(id:tweet_streamer_id).first
  end

end