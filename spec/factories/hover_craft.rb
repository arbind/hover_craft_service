FactoryGirl.define do
  factory :hover_craft do

    trait :twitter do
      twitter_id            { generate :twitter_id }
      twitter_name          { generate :twitter_name }
      twitter_screen_name   { twitter_name.squish.gsub(/\s+/, "_") }
      twitter_website_url   { "http://twitter.com/#{twitter_screen_name}"}
      twitter_address       { generate :address }
      twitter_craft         true
    end

    trait :yelp do
      yelp_name             { generate :yelp_name }
      yelp_id               { yelp_name.underscore }
      yelp_href             { "http://yelp.com/#{yelp_id}" }
      yelp_website_url      { generate :href }
      yelp_address          { generate :address }
      yelp_categories       'food'
      yelp_craft            true
    end

    trait :facebook do
      facebook_id           'facebook_id'
      facebook_name         'facebook_name'
      facebook_href         'facebook_href'
      facebook_website_url  'facebook_website_url'
      facebook_address      'facebook_address'
      facebook_craft        true
    end

    trait :website do
      website_url           'website_url'
      website_name          'website_name'
      website_craft         true
    end

    trait :streamer do
      tweet_streamer
    end

    trait :score do
      fit_score             5
      fit_score_name        5
      fit_score_website     5
      fit_score_username    5
    end

    trait :crafted do
      craft_id  'craft_id'
    end

    factory :complete_hover_craft    , traits: [:crafted,  :streamer, :twitter, :yelp, :website, :facebook, :score]

    factory :yelp_hover_craft        , traits: [:yelp]
    factory :twitter_hover_craft     , traits: [:twitter]
    factory :website_hover_craft     , traits: [:website]
    factory :facebook_hover_craft    , traits: [:facebook]

    factory :no_yelp_hover_craft     , traits: [:crafted, :streamer, :twitter, :facebook, :website, :score]
    factory :no_twitter_hover_craft  , traits: [:crafted, :yelp, :facebook, :website, :score]
    factory :no_website_hover_craft  , traits: [:crafted, :streamer, :twitter, :yelp, :facebook, :score]
    factory :no_facebook_hover_craft , traits: [:crafted, :streamer, :twitter, :yelp, :website, :score]
  end
end