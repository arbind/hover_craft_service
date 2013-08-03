gem 'sidekiq', ">= 0"
WORKER_THREADS ||= {}

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
      load Gem.bin_path('sidekiq', 'sidekiq', ">= 0")
    end
  end
end

if ENV["LAUNCH_BACKGROUND_THREADS"]
  SidekiqProcess.launch launch_delay: 3
end