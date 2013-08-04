class PerformAfterUndefined < Exception
  def initialize(name)
    super "Usage:\nclass #{name}\n  include Sidekiq::Worker\n  include Sidekiq::ScheduledWorker\n  @perform_after = 3.seconds\nend"
  end
end

module Sidekiq
  module ScheduledWorker
    extend ActiveSupport::Concern

    module ClassMethods
      def mutex
        @mutex ||= Mutex.new
      end

      def last_run_at
        return @last_run_at unless @last_run_at.nil?
        scheduledSet = Sidekiq::ScheduledSet.new
        scheduledSet.select.reverse_each do |entry|
          return @last_run_at=entry.score if @queue.eql? entry.queue and name.eql entry.item['class']
        end
        @last_run_at ||= Time.now.to_f
      end

      def next_run_at
        raise PerformAfterUndefined.new(name) unless @perform_after and @perform_after >0.1 and @perform_after < 1_000_000_000
        mutex.synchronize {
          now = Time.now.to_f
          if now > (last_run_at + @perform_after)
            next_run = now
          else
            next_run = last_run_at + @perform_after
          end
          @last_run_at = next_run
        }
      end

      def schedule(*args)
        client_push('class' => self, 'args' => args, 'at' => next_run_at)
      end
    end
  end
end