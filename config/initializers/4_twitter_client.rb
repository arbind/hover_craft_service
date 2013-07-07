Twitter.configure do |config|
  config.consumer_key = SECRET::TWITTER::KEY
  config.consumer_secret = SECRET::TWITTER::SECRET
end

# Eventually Use TwitterClientPool instead:
# Twitter::Client.new consumer_key: SECRET::TWITTER::KEY, consumer_secret: SECRET::TWITTER::SECRET


# twitter rate limit window
TWITTER_RATE_LIMIT_WINDOW = 15 * 60 # in seconds

# number of seconds to wait before making next twitter request
def wait_time_for_request_limit_of(num_requests_per_window)
  num_requests = num_requests_per_window - 1
  safety_seconds = 2
  (TWITTER_RATE_LIMIT_WINDOW / num_requests) + safety_seconds
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
