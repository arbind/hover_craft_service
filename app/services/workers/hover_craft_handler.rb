class HoverCraftHandler

  def self.beam_up_craft(hover_craft)
    HoverCraft.service.beam_up_craft hover_craft
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

  def self.last_scheduled_job_for_hover_craft(hover_craft)
    hover_craft_id = hover_craft.id.to_s
    pending_hover_craft_jobs = nil
    Thread.exclusive do # 1 Sidekiq client connection at a time
      scheduled_jobs  = Sidekiq::ScheduledSet.new
      pending_hover_craft_jobs = scheduled_jobs.select{|job| data = job.args.first;  data and data.has_value? hover_craft_id }
    end
    pending_hover_craft_jobs[-1] if pending_hover_craft_jobs.any?
  end

end