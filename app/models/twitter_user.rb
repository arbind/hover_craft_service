class TwitterUser
  include Mongoid::Document
  include Mongoid::Timestamps

  field :twitter_id
  field :screen_name
  field :name
  field :twitter_account_created_at

  index({twitter_id: 1}, { unique: true, sparse: true })
end