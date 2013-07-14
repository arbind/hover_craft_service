# assumes all friends of a TweetStreamer are verified TwitterCrafts
class YelpJobs < JobServiceBase
  GROUP = :yelp

  def self.pull_yelp_craft_for_new_twitter_crafts
    HoverCraft.with_tweet_streamer.without_yelp_craft.each do |hover_craft|
      pull_yelp_craft_for_new_twitter_craft hover_craft
    end
  end

  def self.pull_yelp_craft_for_new_twitter_craft(hover_craft)
    q_pull_yelp_craft_for_twitter hover_craft
  end

private

  def self.q_pull_yelp_craft_for_twitter(hover_craft)
    key   = :pull_yelp_craft_for_twitter
    return unless hover_craft
    return if hover_craft.yelp_id
    return unless hover_craft.twitter_name and hover_craft.twitter_screen_name
    tweet_streamer = hover_craft.tweet_streamer
    place = tweet_streamer.address if tweet_streamer
    place ||= hover_craft.twitter_address
    return unless place

    uid      = "yelp.for.#{hover_craft.twitter_screen_name}"
    biz_name = hover_craft.twitter_name
    job      = {hover_craft_id:hover_craft.id, biz_name: biz_name, place: place }
    JobQueue.enqueue(key, uid, job, GROUP)
  end

  def self.process_pull_yelp_craft_for_twitter(job)
    hover_craft_id = job.hover_craft_id
    biz_name = job.biz_name
    place = job.place
    hover_craft = HoverCraft.where(id:hover_craft_id).first
    return unless hover_craft
    biz = YelpApi.service.biz_for_name(biz_name, place)
    biz ||= HashObject.new({yelp_id: ""})
    hover_craft.update_attributes biz.to_hover_craft
  end
end

