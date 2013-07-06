class TweetStreamer < TwitterUser
  include Mongoid::Document
  include Mongoid::Timestamps

  field :twitter_id
  field :token
  field :secret

  field :screen_name
  field :name
  field :twitter_account_created_at

  field :utc_offset
  field :time_zone
  field :geo_enabled
  field :statuses_count
  field :lang
  field :default_profile_image
  field :friends, type: Array, default: []

  field :address, default: nil
  field :coordinates, type: Array, default: []

  geocoded_by :address
  reverse_geocoded_by :coordinates

  before_save :geocode_this_location!

  index({twitter_id: 1}, { unique: true, sparse: true })
end
