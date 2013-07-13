ENV["APPLICATION_URL"] ||= "http://0.0.0.0:3000"

module SECRET

  module TWITTER
    KEY     = ENV["TWITTER_KEY"]
    SECRET  = ENV["TWITTER_SECRET"]
  end

  module YELP # http://www.yelp.com/developers/manage_api_keys facebook[arbind.thakur] or arbind.thakur@gmail.com/!light
    module V1 # Yelp API V1.0 uses Yelp Web Service ID:
      YWS_ID = ENV["YELP_YWS_ID"]
    end

    module V2 # Yelp API v2.0 uses OAUTH:
      CONSUMER_KEY     = ENV["YELP_CONSUMER_KEY"]
      CONSUMER_SECRET  = ENV["YELP_CONSUMER_SECRET"]
      TOKEN            = ENV["YELP_TOKEN"]
      TOKEN_SECRET     = ENV["YELP_TOKEN_SECRET"]
    end
  end
end