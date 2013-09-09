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

      def perform_after
        @perform_after
      end

      def last_run_at
        return @last_run_at unless @last_run_at.nil?
        scheduledSet = Sidekiq::ScheduledSet.new
        scheduledSet.select.reverse_each do |entry|
          return @last_run_at=entry.score if @queue.eql? entry.queue and name.eql entry.item['class']
        end
        @last_run_at ||= (Time.now - interval_between_runs).to_f
      end

      def interval_between_runs
        return @interval_between_runs if @interval_between_runs
        raise PerformAfterUndefined.new(name) unless @perform_after
        @interval_between_runs = @perform_after.to_i
        raise PerformAfterUndefined.new(name) if @interval_between_runs < 0.1
        @interval_between_runs
      end

      def next_run_at
        mutex.synchronize {
          now = Time.now.to_f
          if now > (last_run_at + interval_between_runs)
            next_run = now
          else
            next_run = last_run_at + interval_between_runs
          end
          @last_run_at = next_run
        }
      end

      def config_scheduled_worker
        if @config_scheduled_worker.nil?
          @config_scheduled_worker = true
          sidekiq_options :queue => name.to_sym, :retry => false, :backtrace => true
        end
      end

      def schedule(*args)
        config_scheduled_worker
        before_schedule(*args) if respond_to? :before_schedule
        client_push('class' => self, 'args' => args, 'at' => next_run_at)
        after_schedule(*args) if respond_to? :after_schedule
      end
      def delay_schedule_until(duration_to_wait, *args)
        config_scheduled_worker
        before_schedule(*args) if respond_to? :before_schedule
        client_push('class' => self, 'args' => args, 'at' => next_run_at + duration_to_wait)
        after_schedule(*args) if respond_to? :after_schedule
      end
    end
  end
end