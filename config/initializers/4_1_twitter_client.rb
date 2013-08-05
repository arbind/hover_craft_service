Twitter.configure do |config|
  config.consumer_key = SECRET::TWITTER::KEY
  config.consumer_secret = SECRET::TWITTER::SECRET
end

# Eventually usr a pool of TwitterClients instead:
# Twitter::Client.new consumer_key: SECRET::TWITTER1::KEY, consumer_secret: SECRET::TWITTER1::SECRET
# Twitter::Client.new consumer_key: SECRET::TWITTER2::KEY, consumer_secret: SECRET::TWITTER2::SECRET
# Twitter::Client.new consumer_key: SECRET::TWITTER3::KEY, consumer_secret: SECRET::TWITTER3::SECRET

# twitter rate limit window (for each deveoper app, for each twitter resource)
ENV["TWITTER_RATE_LIMIT_WINDOW"] ||= "15" # in minutes
TWITTER_WINDOW = 60 * ENV["TWITTER_RATE_LIMIT_WINDOW"].to_i # in seconds

# request limits for each resource per application
# https://dev.twitter.com/docs/rate-limiting/1.1/limits
# (Requests allotted via application-only auth)
INTERVAL_FOR_TWITTER_RATE_LIMITS = {
  user:       wait_time_for_request_limit_of(180, TWITTER_WINDOW),
  users:      wait_time_for_request_limit_of(60, TWITTER_WINDOW),
  friends:    wait_time_for_request_limit_of(30, TWITTER_WINDOW),
  friend_ids: wait_time_for_request_limit_of(15, TWITTER_WINDOW),
}

TWITTER_FETCH_USERS_BATCH_SIZE = ENV["TWITTER_FETCH_USERS_BATCH_SIZE"] ? ENV["TWITTER_FETCH_USERS_BATCH_SIZE"].to_i : 100

ENV["TWEET_STREAMER_REFRESH_INTERVAL"] ||= (1).to_s