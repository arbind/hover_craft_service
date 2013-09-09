class HoverCraftHandler

  def self.beam_up_craft(hover_craft)
    last_scheduled_job = last_scheduled_job_for_hover_craft hover_craft
    if last_scheduled_job.present?
      duration_to_wait = 2.minutes + (last_scheduled_job.score - Time.now.to_i)
      WorkLauncher.launch_after_waiting duration_to_wait, :beam_up_craft, hover_craft # requeue this job
    else
      HoverCraft.service.beam_up_craft hover_craft
    end
  end

  def self.populate_hover_crafts(nada={})
    HoverCraft.with_missing_web_craft.each do |hc|
      WorkLauncher.launch :populate_hover_craft, hc
    end
  end

  def self.populate_hover_craft(hover_craft)
    WorkLauncher.launch :populate_twitter_craft, hover_craft unless hover_craft.twitter_id and hover_craft.twitter_name
    WorkLauncher.launch :populate_facebook_craft, hover_craft unless hover_craft.facebook_id and hover_craft.facebook_name
    WorkLauncher.launch :populate_yelp_craft, hover_craft unless hover_craft.yelp_id and hover_craft.yelp_name
    WorkLauncher.launch :populate_website_craft, hover_craft unless hover_craft.website_url
  end

  def self.hover_craft_resolve_url(hover_craft, url_attribute)
    HoverCraft.service.resolve_url hover_craft, url_attribute
    WorkLauncher.launch :populate_hover_craft, hover_craft
  end

private
  def self.last_scheduled_job_for_hover_craft(hover_craft)
    hover_craft_id = hover_craft.id.to_s
    scheduled_jobs  = Sidekiq::ScheduledSet.new
    pending_hover_craft_jobs = scheduled_jobs.select{|job| data = job.args.first;  data and data.has_value? hover_craft_id }
    if pending_hover_craft_jobs.any?
      pending_hover_craft_jobs[-1]
    else
      nil
    end
  end

end