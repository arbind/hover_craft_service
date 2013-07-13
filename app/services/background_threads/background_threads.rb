BACKGROUND_THREADS = {}

module BackgroundThreads
  def self.launch(name, interval, options={})
    name = name.to_sym
    interval = interval.to_i
    raise Exception, "#{name} already launched" if BACKGROUND_THREADS[name]
    description  = options[:description]  || name
    launch_delay = options[:launch_delay] || 0
    launch_delay = launch_delay.to_i
    BACKGROUND_THREADS[name] = Thread.new do
      Thread.current[:name] = name
      Thread.current[:description] = description
      puts ":: BackgroundThreads launched [every #{interval}s]: #{description}"
      sleep launch_delay if 0 < launch_delay
      loop do
        puts ":: BackgroundThreads runing [every #{interval}s]: #{description}"
        begin
          yield
        rescue Exception => ex
          puts ex.message
        end
        sleep interval
      end
    end
  end
end