class WorkerResolveHoverCraftUrl
  include Sidekiq::Worker
  include Sidekiq::ScheduledWorker
  @perform_after = 1

  def self.work_data(hover_craft_id, url_attribute='twitter_website_url')
    {
      "hover_craft_id" => hover_craft_id,
      "url_attribute"  => url_attribute
    }
  end

  def perform(data)
    hover_craft_id = data.fetch 'hover_craft_id'
    url_attribute = data.fetch 'url_attribute'

    if resolve_url(hover_craft_id, url_attribute)
      schedule_find_web_crafts hover_craft_id
    end
  end

private

  def resolve_url(hover_craft_id, url_attribute)
    hover_craft = HoverCraft.find hover_craft_id
    first_url = hover_craft[url_attribute]
    hover_craft[url_attribute] =Web.final_location_of_url first_url
    hover_craft.save
    !(hover_craft[url_attribute].eql? first_url )
  end

  def schedule_find_web_crafts(hover_craft_id)
    job_data = WorkerFindWebCrafts.work_data hover_craft_id
    WorkerFindWebCrafts.schedule job_data
  end

  def log(info={})
    msg = "Resolved url: #{info[:url]} ->  #{info[:final_url]}"
    Rails.logger.info msg
  end
end