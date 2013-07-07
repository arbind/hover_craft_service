class TweetStreamer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include GeoAliases

  field :twitter_id
  field :name
  field :screen_name
  field :twitter_account_created_at

  field :token
  field :secret

  field :lang
  field :geo_enabled
  field :friends        , type: Array   , default: []

  # geocoder fields
  field :address                        , default: nil
  field :location_hash  , type: Hash    , default: {}
  field :coordinates    , type: Array   , default: []

  geocoded_by :address
  reverse_geocoded_by :coordinates

  before_save :geocode_this_location!

  index({twitter_id: 1}, { unique: true, sparse: true })
end
