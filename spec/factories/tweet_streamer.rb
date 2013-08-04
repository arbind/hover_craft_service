FactoryGirl.define do
  factory :tweet_streamer do
    name        { FactoryGirl.generate :streamer_name }
    address     { FactoryGirl.generate :streamer_address }
    twitter_id  { FactoryGirl.generate :streamer_twitter_id }
    screen_name { FactoryGirl.generate :streamer_screen_name }
  end
end