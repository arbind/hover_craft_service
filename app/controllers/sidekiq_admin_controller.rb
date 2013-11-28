class SidekiqAdminController < ApplicationProtectedController
  def index
    @scheduled_jobs_count =  SidekiqService.num_scheduled_jobs
  end

  def clear_scheduled_jobs
    SidekiqService.clear_scheduled_jobs
    redirect_to :sidekiq_admin_index
  end

  def clear_stats
    SidekiqService.clear_all_stats
    redirect_to :sidekiq_admin_index
  end

end
