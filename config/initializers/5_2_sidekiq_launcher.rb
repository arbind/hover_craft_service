WORKER_THREADS ||= {}

def sidekiq_workers
  Dir.glob(File.join('app/workers', "*")).map{|fn| fn.split('/').last.split('.').first}.map(&:camelcase)
end

def sidekiq_launch_args
  args = []
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

sidekiq_redis_conn = proc {
  uri = URI.parse( REDIS_URI )
  Redis.new(:host => uri.host, :port => uri.port, :password => uri.password) rescue nil
}

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 55, &sidekiq_redis_conn)
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 55, &sidekiq_redis_conn)
end

if ENV["LAUNCH_BACKGROUND_JOBS"]
  SidekiqProcess.launch launch_delay: 3
end