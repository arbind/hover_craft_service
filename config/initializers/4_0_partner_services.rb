# number of seconds to wait before making next request (everything in seconds)
def wait_time_for_request_limit_of(num_requests_per_window, window)
  num_requests = num_requests_per_window - 1
  safety_seconds = 2
  (window / num_requests) + safety_seconds
end
