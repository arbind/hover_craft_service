FactoryGirl.define do
  factory :hover_craft do
    factory :twitter_hover_craft do
      twitter_id            { FactoryGirl.generate :twitter_id }
      twitter_name          { FactoryGirl.generate :name }
      twitter_screen_name   { FactoryGirl.generate :screen_name }
    end

    factory :yelp_hover_craft do
      yelp_id               { FactoryGirl.generate :yelp_id }
      yelp_name             { FactoryGirl.generate :name }
      yelp_href             { FactoryGirl.generate :yelp_href }
    end


    factory :complete_hover_craft do
      craft_id  'craft_id'
      tweet_streamer_id 'tweet_streamer_id'

      twitter_id            { FactoryGirl.generate :twitter_id }
      twitter_name          { FactoryGirl.generate :name }
      twitter_screen_name   { FactoryGirl.generate :screen_name }
      twitter_website_url   'twitter_website_url'
      twitter_address       'twitter_address'
      twitter_craft         true

      yelp_id               'yelp_id'
      yelp_name             'yelp_name'
      yelp_href             'yelp_href'
      yelp_website_url      'yelp_website_url'
      yelp_address          'yelp_address'
      yelp_categories       'yelp_categories'
      yelp_craft true

      facebook_id           'facebook_id'
      facebook_name         'facebook_name'
      facebook_href         'facebook_href'
      facebook_website_url  'facebook_website_url'
      facebook_address      'facebook_address'
      facebook_craft        true

      website_url           'website_url'
      website_name          'website_name'
      website_craft         true

      fit_score             5
      fit_score_name        5
      fit_score_website     5
      fit_score_username    5

      factory :missing_twitter do
        tweet_streamer_id   nil
        twitter_id          nil
        twitter_name        nil
        twitter_screen_name nil
        twitter_website_url nil
        twitter_address     nil
        twitter_profile     nil
        twitter_craft       nil
      end
      factory :missing_yelp do
        yelp_id             nil
        yelp_name           nil
        yelp_href           nil
        yelp_website_url    nil
        yelp_address        nil
        yelp_categories     nil
        yelp_profile        nil
        yelp_craft          nil
      end
      factory :missing_facebook do
        facebook_id         nil
        facebook_name       nil
        facebook_href       nil
        facebook_website_url nil
        facebook_address    nil
        facebook_profile    nil
        facebook_craft      nil
      end
      factory :missing_website do
        website_url         nil
        website_name        nil
        website_profile     nil
        website_craft       nil
      end
    end
  end
end