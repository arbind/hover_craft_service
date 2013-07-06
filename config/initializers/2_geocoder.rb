GEOCODER_CACHE_TTL = 86400 # (60s * 60m * 24h)

geocoder_config = {
  lookup: :google,
  cache: RedisAutoExpire.new(REDIS4GEOCODER, GEOCODER_CACHE_TTL),
  cache_prefix: "gO:" # gee-oooh :)
}

Geocoder.configure geocoder_config