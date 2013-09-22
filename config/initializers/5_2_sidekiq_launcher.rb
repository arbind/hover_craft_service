WORKER_THREADS ||= {}

# Crank these UP!
# Free heroku RedisToGo only allows 10 connections tho!
# Also, REDIS and REDIS4GEOCODER are already 2 connections to redis!
# Keep in mind that some serverside workers use sidekiq client (i.e. BeamUpCraft)
SIDEKIQ_CONCURRENCY_COUNT = (ENV["SIDEKIQ_CONCURRENCY_COUNT"] || 10).to_i
SIDEKIQ_CLIENT_REDIS_POOL_SIZE = (ENV["SIDEKIQ_CLIENT_REDIS_POOL_SIZE"] || 3).to_i
SIDEKIQ_SERVER_REDIS_POOL_SIZE = (ENV["SIDEKIQ_SERVER_REDIS_POOL_SIZE"] || 4).to_i

sidekiq_redis_conn = proc {
  uri = URI.parse(REDIS_URI)
  Redis.new(:host => uri.host, :port => uri.port, :password => uri.password) rescue nil
}

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 3, &sidekiq_redis_conn)
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 14, &sidekiq_redis_conn)
end

def sidekiq_workers
  Dir.glob(File.join('app/workers', "*")).map{|fn| fn.split('/').last.split('.').first}.map(&:camelcase)
end

def sidekiq_launch_args
  args = []
  args << '-c' << "#{SIDEKIQ_CONCURRENCY_COUNT}"
  sidekiq_workers.each{|q| args << '-q' << q }
  args << '-q' << 'default'
  args
end

module SidekiqProcess
  def self.launch(options={})
    name = :sidekiq
    raise Exception, "#{name} already launched" if WORKER_THREADS[name]
    description  = options[:description]  || name
    launch_delay = options[:launch_delay] || 0
    launch_delay = launch_delay.to_i
    WORKER_THREADS[name] = Thread.new do
      Thread.current[:name] = name
      Thread.current[:description] = description
      sleep launch_delay if 0 < launch_delay
      old_ARGV = ARGV
      ARGV.replace sidekiq_launch_args
      p "starting sidekiq queues:", ARGV
      load Gem.bin_path('sidekiq', 'sidekiq', ">= 0")
      ARGV.replace old_ARGV
    end
  end
end

if ENV["LAUNCH_BACKGROUND_JOBS"]
  SidekiqProcess.launch launch_delay: 3
end