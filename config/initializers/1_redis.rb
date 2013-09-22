REDIS_URI = ENV["REDISTOGO_URL"] || ENV["REDIS_URL"] || "redis://localhost:6379/"

unless $PROGRAM_NAME.end_with?('rake')
  # Skip this initialization durring rake tasks
  # Heroku runs rake asset:precompile in sandbox mode with no ENV or DBs
  REDIS_DB_ENVIRONMENTS = {
    'production'    => 0,
    :production     => 0,

    'development'   => 1,
    :'development'  => 1,

    'test'          => 2,
    :test           => 2
  }

  def select_redis_db_num(redis, db_num)
    return if redis.nil? or Rails.env.production? # keep default in production
    redis.select db_num
  end

  uri = URI.parse( REDIS_URI )

  REDIS_DB = REDIS_DB_ENVIRONMENTS[ (ENV["RAILS_ENV"] || :development) ]

  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password) rescue nil

  select_redis_db_num REDIS, REDIS_DB

  REDIS4GEOCODER = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password) rescue nil
  select_redis_db_num REDIS4GEOCODER, 3 + REDIS_DB

  puts "\nredis is not running on #{uri}\n!!!" if REDIS.nil?
  puts "\nredis geocoder cache is not running on #{uri}\n!!!" if REDIS4GEOCODER.nil?
end