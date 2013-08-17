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
      Thread.current[:run_number] = 0
      Thread.current[:default_interval] = interval
      Thread.current[:interval] = interval
      Thread.current[:errors] = []
      Thread.current[:last_run_started] = nil
      Thread.current[:last_run_completed] = nil
      puts ":: BackgroundThreads launched [every #{interval}s]: #{description}"
      sleep launch_delay if 0 < launch_delay
      loop do
        Thread.current[:run_number] += 1
        puts ":: BackgroundThreads runing [every #{interval}s]: #{description}"
        Thread.current[:status] = :running
        begin
          Thread.current[:last_run_completed] = nil
          Thread.current[:last_run_started] = Time.now
          yield
          Thread.current[:last_run_completed] = Time.now
        rescue Exception => ex
          Thread.current[:status] = :failed
          Thread.current[:errors] << ex
          puts "!! !! #{ex.message}"
        end
        Thread.current[:status] = :sleeping unless :failed == Thread.current[:status]
        Thread.current[:next_run] = Time.now + interval
        sleep Thread.current[:interval]
      end
    end
  end
end