unless $PROGRAM_NAME.end_with?('rake')
  # Skip this initialization durring rake tasks
  # Heroku runs rake asset:precompile in sandbox mode with no ENV or DBs
  GEOCODER_CACHE_TTL = 86400 # (60s * 60m * 24h)

  geocoder_config = {
    lookup: :google,
    cache: RedisAutoExpire.new(REDIS4GEOCODER, GEOCODER_CACHE_TTL),
    cache_prefix: "gO:" # gee-oooh :)
  }

  Geocoder.configure geocoder_config
end