class HoverCraftSvc

  def self.score(hover_craft)
    calculate_yelp_fit_score      hover_craft
    calculate_website_fit_score   hover_craft
    calculate_twitter_fit_score   hover_craft
    calculate_facebook_fit_score  hover_craft
    calculate_craft_fit_score     hover_craft
  end

  private

  def self.calculate_twitter_fit_score(hover_craft)
    return if hover_craft.twitter_craft   # already crafted
    return if hover_craft.twitter_id.nil? # nothing to score
    return if HoverCraft::FIT_sudo_approved.eql? hover_craft.twitter_fit_score # already approved by admin

    score = hover_craft.twitter_fit_score || HoverCraft::FIT_check_manually
    if hover_craft.tweet_streamer and hover_craft.twitter_name
      score = HoverCraft::FIT_auto_approved # auto approve streamer friend
    elsif StringDistance.match? hover_craft.twitter_name, hover_craft.yelp_name
      score = HoverCraft::FIT_absolute  # matched yelp name
    elsif Web.hosts_match? hover_craft.twitter_website_url, hover_craft.website_url
      score = HoverCraft::FIT_absolute # website matched
    elsif hover_craft.website_profile.present? and hover_craft.website_profile[:twitter_links]
      hover_craft.website_profile[:twitter_links].each do |link|
        score = HoverCraft::FIT_absolute if StringDistance.match? link, hover_craft.twitter_href # twitter_href found on website
      end
    end
    hover_craft.twitter_fit_score = score
  end

  def self.calculate_yelp_fit_score(hover_craft)
    return if hover_craft.yelp_craft   # already crafted
    return if hover_craft.yelp_id.nil? # nothing to score
    return if HoverCraft::FIT_sudo_approved.eql? hover_craft.yelp_fit_score # already approved by admin

    score = hover_craft.yelp_fit_score || HoverCraft::FIT_check_manually
    if StringDistance.match? hover_craft.yelp_name, hover_craft.twitter_name
      score = HoverCraft::FIT_absolute  # matched twitter name
    elsif Web.hosts_match? hover_craft.yelp_website_url, hover_craft.website_url
      score = HoverCraft::FIT_absolute # website matched
    elsif hover_craft.website_profile.present? and hover_craft.website_profile[:yelp_links]
      hover_craft.website_profile[:yelp_links].each do |link|
        score = HoverCraft::FIT_absolute if StringDistance.match? link, hover_craft.yelp_href, 10 # yelp_href found on website
      end
    end
    hover_craft.yelp_fit_score = score
  end

  def self.calculate_facebook_fit_score(hover_craft)
    return if hover_craft.facebook_craft   # already crafted
    return if hover_craft.facebook_id.nil? # nothing to score
    return if HoverCraft::FIT_sudo_approved.eql? hover_craft.facebook_fit_score # already approved by admin

    score = hover_craft.facebook_fit_score || HoverCraft::FIT_check_manually
    if StringDistance.match? hover_craft.facebook_name, hover_craft.twitter_name
      score = HoverCraft::FIT_absolute  # matched twitter name
    elsif StringDistance.match? hover_craft.facebook_name, hover_craft.yelp_name
      score = HoverCraft::FIT_absolute  # matched yelp name
    elsif Web.hosts_match? hover_craft.facebook_website_url, hover_craft.website_url
      score = HoverCraft::FIT_absolute # website matched
    elsif hover_craft.website_profile.present? and hover_craft.website_profile[:facebook_links]
      hover_craft.website_profile[:facebook_links].each do |link|
        score = HoverCraft::FIT_absolute if StringDistance.match? link, hover_craft.facebook_href, 10 # facebook_href found on website
      end
    end
    hover_craft.facebook_fit_score = score
  end

  def self.calculate_website_fit_score(hover_craft)
    return if hover_craft.website_craft    # already crafted
    return if hover_craft.website_url.nil? # nothing to score
    return if HoverCraft::FIT_sudo_approved.eql? hover_craft.website_fit_score # already approved by admin

    score = hover_craft.website_fit_score || HoverCraft::FIT_check_manually
    if Web.hosts_match? hover_craft.website_url, hover_craft.twitter_website_url
    score = HoverCraft::FIT_absolute # website matched
    elsif Web.hosts_match? hover_craft.website_url, hover_craft.yelp_website_url
    score = HoverCraft::FIT_absolute # website matched
    elsif Web.hosts_match? hover_craft.website_url, hover_craft.facebook_website_url
      score = HoverCraft::FIT_absolute # website matched
    elsif hover_craft.website_profile.present?
      if hover_craft.website_profile[:twitter_links]
        hover_craft.website_profile[:twitter_links].each do |link|
          score = HoverCraft::FIT_absolute if StringDistance.match? link, hover_craft.twitter_href, 10 # twitter_href found on website
        end
      end
      if hover_craft.website_profile[:yelp_links]
        hover_craft.website_profile[:yelp_links].each do |link|
        score = HoverCraft::FIT_absolute if StringDistance.match? link, hover_craft.yelp_href, 10 # yelp_href found on website
        end
      end
      if hover_craft.website_profile[:facebook_links]
        hover_craft.website_profile[:facebook_links].each do |link|
        score = HoverCraft::FIT_absolute if StringDistance.match? link, hover_craft.facebook_href, 10 # facebook_href found on website
        end
      end
    end
    hover_craft.website_fit_score = score
  end


  def self.calculate_craft_fit_score(hover_craft)
    sum = 0.0
    total = 0
    [:twitter, :yelp, :facebook, :website].each do |provider|
      if hover_craft.send(:"#{provider}_id")
        sum += hover_craft[:"#{provider}_fit_score"].to_i
        total += 1
      end
    end
    total = -100 if 0.eql? total
    hover_craft.craft_fit_score = (sum/total).round
  end

  def self.attribute_for_providers(hover_craft, attr_name, providers)
    values = providers.map{|provider| hover_craft[:"#{provider}_#{attr_name}"]}
    values.reject!{|v| v.nil?}
  end
end