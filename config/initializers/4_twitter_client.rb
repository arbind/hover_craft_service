Twitter.configure do |config|
  config.consumer_key = SECRET::TWITTER::KEY
  config.consumer_secret = SECRET::TWITTER::SECRET
end

# Eventually Use Pool TwitterClients instead:
# Twitter::Client.new consumer_key: SECRET::TWITTER1::KEY, consumer_secret: SECRET::TWITTER1::SECRET
# Twitter::Client.new consumer_key: SECRET::TWITTER2::KEY, consumer_secret: SECRET::TWITTER2::SECRET
# Twitter::Client.new consumer_key: SECRET::TWITTER3::KEY, consumer_secret: SECRET::TWITTER3::SECRET

# twitter rate limit window (for each deveoper app, for each twitter resource)
ENV["TWITTER_RATE_LIMIT_WINDOW"] ||= "15" # in minutes

# number of seconds to wait before making next twitter request
def wait_time_for_request_limit_of(num_requests_per_window)
  window = 60 * ENV["TWITTER_RATE_LIMIT_WINDOW"].to_i # in seconds
  num_requests = num_requests_per_window - 1
  safety_seconds = 2
  (window / num_requests) + safety_seconds
end

# request limits for each resource per application
# https://dev.twitter.com/docs/rate-limiting/1.1/limits
# (Requests allotted via application-only auth)
INTERVAL_FOR_TWITTER_RATE_LIMITS = {
  user:       wait_time_for_request_limit_of(180),
  users:      wait_time_for_request_limit_of(60),
  friends:    wait_time_for_request_limit_of(30),
  friend_ids: wait_time_for_request_limit_of(15),
}
