class HoverCraft
  include Mongoid::Document
  include Mongoid::Timestamps

  # score constants
  FIT_unknown =  -100
  FIT_duplicate_crafts = -2
  FIT_need_to_explore = -1
  FIT_zero = 0                # its not a fit
  FIT_missing_craft = 1
  FIT_check_manually = 3
  FIT_neutral = 5             # at least its not a bad fit
  FIT_absolute = 8            # analyzed to be a good fit
  FIT_auto_approved = 10      # automatically approved
  FIT_sudo_approved = 20      # manually approved by super user

  belongs_to :tweet_streamer  , inverse_of: nil
  field :craftable            , type: Boolean

  field :craft_id
  field :craft_fit_score      , type: Integer, default: -100

  field :yelp_fit_score       , type: Integer
  field :yelp_id
  field :yelp_name
  field :yelp_href
  field :yelp_website_url
  field :yelp_address
  field :yelp_categories
  field :yelp_profile         , type: Hash
  field :yelp_craft           , type: Boolean

  field :website_fit_score    , type: Integer
  field :website_url
  alias_method :website_id    , :website_url
  alias_method :website_href  , :website_url
  field :website_name
  field :website_profile      , type: Hash
  field :website_craft        , type: Boolean

  field :twitter_fit_score    , type: Integer
  field :twitter_id
  field :twitter_name
  field :twitter_screen_name
  field :twitter_website_url
  field :twitter_address
  field :twitter_profile      , type: Hash
  field :twitter_craft        , type: Boolean

  field :facebook_fit_score   , type: Integer
  field :facebook_id
  field :facebook_name
  field :facebook_href
  field :facebook_website_url
  field :facebook_address
  field :facebook_profile     , type: Hash
  field :facebook_craft       , type: Boolean

  # override flags
  field :approve_this         , type: Boolean
  field :flag_this            , type: Boolean # Needs follow up for corrections
  field :skip_this            , type: Boolean

  scope :crafted              , excludes(craft_id: nil).desc(:craft_fit_score)
  scope :uncrafted            , where(craft_id: nil).desc(:craft_fit_score)

  scope :can_craft            , where(craftable: true)
  scope :can_not_craft        , excludes(craftable: true)

  scope :flagged              , where(flag_this: true)
  scope :skipped              , where(skip_this: true)
  scope :unflagged            , excludes(flag_this: true)
  scope :unskipped            , excludes(skip_this: true)

  # crafts with both twitter and yelp
  scope :twelps               , excludes(yelp_id: nil).excludes(twitter_id: nil).desc(:yelp_name)

  scope :with_yelp            , excludes(yelp_id: nil)
  scope :with_twitter         , excludes(twitter_id: nil)
  scope :with_website         , excludes(website_url: nil)
  scope :with_facebook        , excludes(facebook_id: nil)

  scope :without_yelp         , where(yelp_id: nil)
  scope :without_twitter      , where(twitter_id: nil)
  scope :without_website      , where(website_url: nil)
  scope :without_facebook     , where(facebook_id: nil)
  scope :without_streamer     , where(tweet_streamer_id: nil)

  scope :with_missing_web_craft, any_of( {yelp_id: nil},
                                     {twitter_id: nil},
                                     {facebook_id: nil},
                                     {website_url: nil}
                                   ).desc(:yelp_name).desc(:twitter_name)

  before_save :format_hrefs
  before_save :score

  def self.service
    ::HoverCraftSvc
  end

  def twitter_href
    TwitterApi.twitter_href_for_screen_name twitter_screen_name
  end

  def twitter_href=(href)
    self.twitter_screen_name = TwitterApi.twitter_screen_name_from_href href
  end

  def populated?
    twitter_id and yelp_id and facebook_id and website_url
  end

  # score scopes
  def self.need_to_explore(provider)
    where(:"#{provider}_fit_score" => FIT_need_to_explore)
  end
  def self.check_manually(provider)
    where(:"#{provider}_fit_score" => FIT_check_manually)
  end
  def self.missing_craft(provider)
    where(:"#{provider}_fit_score" => FIT_missing_craft)
  end
  def self.zero_fit(provider)
    where(:"#{provider}_fit_score" => FIT_zero)
  end
  def self.neutral_fit(provider)
    where(:"#{provider}_fit_score" => FIT_neutral)
  end
  def self.absolute_fit(provider)
    where(:"#{provider}_fit_score" => FIT_absolute)
  end

private

  def format_hrefs
    self.yelp_href = self.yelp_href.to_href if self.yelp_href
    self.facebook_href = self.facebook_href.to_href if self.facebook_href
    self.website_url = self.website_url.to_href if self.website_url
    self.yelp_website_url = self.yelp_website_url.to_href if self.yelp_website_url
    self.twitter_website_url = self.twitter_website_url.to_href if self.twitter_website_url
    self.facebook_website_url = self.facebook_website_url.to_href if self.facebook_website_url
    true
  end

  def score
    HoverCraft.service.score self
  end

end