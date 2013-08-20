FactoryGirl.define do
  factory :tweet_streamer do
    name        { generate :streamer_name }
    address     { generate :streamer_address }
    twitter_id  { generate :streamer_twitter_id }
    screen_name { name.underscore }
  end
end