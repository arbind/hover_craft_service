FactoryGirl.define do
  sequence(:href)                 { |n| "http://my-site-#{n}.com" }

  sequence(:name)                 { |n| "Prince the #{n}th" }
  sequence(:address)              { |n| "Santa Monica, Ca" }

  sequence(:streamer_twitter_id)  { |n| "8888#{n}" }
  sequence(:streamer_name)        { |n| "Streamer #{n}" }
  sequence(:streamer_address)     { |n| "Los Angeles, Ca" }

  sequence(:twitter_id)           { |n| "100#{n}" }
  sequence(:twitter_name)         { |n| "Tweeter #{n}" }
  sequence(:twitter_screen_name)  { |n| "screen_name_#{n}" }

  sequence(:yelp_name)            { |n| "My Biz #{n}" }

  sequence(:facebook_id)          { |n| "200#{n}" }
  sequence(:facebook_name)        { |n| "Face Booker #{n}" }

  sequence(:website_name)         { |n| "My Sweet Website #{n}" }

end