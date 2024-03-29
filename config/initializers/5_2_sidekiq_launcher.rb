WORKER_THREADS ||= {}

# Keep an eye on connection pools when cranking this up!
# see complete control of redis connection pool:
# https://github.com/mperham/sidekiq/wiki/Advanced-Options
SIDEKIQ_CONCURRENCY_COUNT = (ENV["SIDEKIQ_CONCURRENCY_COUNT"] || 25).to_i

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