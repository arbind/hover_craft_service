class HoverCraft
  include Mongoid::Document
  include Mongoid::Timestamps

  field :craft_id

  field :twitter_id
  field :twitter_name
  field :twitter_screen_name
  field :twitter_url
  field :twitter_profile, type: Hash

  field :yelp_id
  field :yelp_name
  field :yelp_url
  field :yelp_profile, type: Hash

  field :facebook_id
  field :facebook_name
  field :facebook_url
  field :facebook_profile, type: Hash

  field :website_url
  field :website_name
  field :website_profile, type: Hash
end