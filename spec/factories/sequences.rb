FactoryGirl.define do
  sequence(:name)         { |n| "Prince the #{n}th" }
  sequence(:address)      { |n| "Santa Monica, Ca" }
  sequence(:twitter_id)   { |n| "100#{n}" }
  sequence(:screen_name)  { |n| "tweeter_#{n}" }

  sequence(:streamer_name)         { |n| "Yumi the #{n}th" }
  sequence(:streamer_address)      { |n| "Los Angeles, Ca" }
  sequence(:streamer_twitter_id)   { |n| "8888#{n}" }
  sequence(:streamer_screen_name)  { |n| "streamer_#{n}" }
end