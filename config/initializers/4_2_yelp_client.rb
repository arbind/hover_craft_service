module SECRET::YELP # http://www.yelp.com/developers/manage_api_keys facebook[arbind.thakur] or arbind.thakur@gmail.com/!light
end

module SECRET::YELP::V1 # Yelp API V1.0 uses Yelp Web Service ID:
  YWS_ID = ENV["YELP_YWS_ID"]
end

module SECRET::YELP::V2 # Yelp API v2.0 uses OAUTH:
  CONSUMER_KEY     = ENV["YELP_CONSUMER_KEY"]
  CONSUMER_SECRET  = ENV["YELP_CONSUMER_SECRET"]
  TOKEN            = ENV["YELP_TOKEN"]
  TOKEN_SECRET     = ENV["YELP_TOKEN_SECRET"]
end

if SECRET::YELP::V2::TOKEN
else
  abort "!! Yelp Client not configured: missing keys" if ENV["IN_SERVER"]
end
ENV["YELP_DAILY_REQUEST_LIMIT"] ||= "1000"
YELP_REQUEST_LIMIT = ENV["YELP_DAILY_REQUEST_LIMIT"].to_i

ENV["YELP_RATE_LIMIT_WINDOW"]   ||= "#{24*60}" # in minutes
YELP_WINDOW = 60 * ENV["YELP_RATE_LIMIT_WINDOW"].to_i # in seconds

if Rails.env.development?
  puts "!! Accelerating Yelp rate limit for development- don't go overboard! "
  INTERVAL_FOR_YELP_RATE_LIMIT = wait_time_for_request_limit_of(10, 15)
else
  INTERVAL_FOR_YELP_RATE_LIMIT = wait_time_for_request_limit_of(YELP_REQUEST_LIMIT, YELP_WINDOW)
end