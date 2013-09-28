class HoverCraftSvc

  def self.beam_up_craft(hover_craft)
    craft_info = craft_for hover_craft
    return nil unless craft_info
    updated_craft = CraftSvc.materialize craft_info
    if updated_craft
      hover_craft.craft_path = updated_craft.craft_path
      hover_craft.yelp_crafted = true if updated_craft.yelp_craft and updated_craft.yelp_craft['web_craft_id']
      hover_craft.twitter_crafted = true if updated_craft.twitter_craft and updated_craft.twitter_craft['web_craft_id']
      hover_craft.website_crafted = true if updated_craft.website_craft and updated_craft.website_craft['web_craft_id']
      hover_craft.facebook_crafted = true if updated_craft.facebook_craft and updated_craft.facebook_craft['web_craft_id']
      hover_craft.save!
    end
    updated_craft
  end

  def self.craft_for(hover_craft)
    return nil unless hover_craft.craftable?
    craft = {}
    yelp_fit_score = hover_craft.yelp_fit_score || 0
    twitter_fit_score = hover_craft.twitter_fit_score || 0
    website_fit_score = hover_craft.website_fit_score || 0
    facebook_fit_score = hover_craft.facebook_fit_score || 0
    craft[:craft_path] = hover_craft.craft_path if hover_craft.craft_path
    craft[:address] = hover_craft.primary_address if hover_craft.primary_address
    craft[:yelp] = yelp_craft_for hover_craft if yelp_fit_score >= HoverCraft::FIT_absolute
    craft[:twitter] = twitter_craft_for hover_craft if twitter_fit_score >= HoverCraft::FIT_absolute
    craft[:website] = website_craft_for hover_craft if website_fit_score >= HoverCraft::FIT_absolute
    craft[:facebook] = facebook_craft_for hover_craft if facebook_fit_score >= HoverCraft::FIT_absolute
    return nil unless craft.present? and (craft[:twitter_craft] or craft[:yelp_craft])
    craft
  end

  def self.score(hover_craft)
    calculate_yelp_fit_score      hover_craft
    calculate_website_fit_score   hover_craft
    calculate_twitter_fit_score   hover_craft
    calculate_facebook_fit_score  hover_craft
    calculate_craft_fit_score     hover_craft
  end

  def self.resolve_url(hover_craft, url_attribute)
    first_url = hover_craft[url_attribute]
    return unless first_url
    first_url = first_url.to_href
    return unless first_url
    final_url = Web.final_location_of_url first_url

    if final_url.present? and !first_url.eql? final_url
      hover_craft[url_attribute] = final_url
      hover_craft.save # run before_save only if needed
    end
  end

  private

  def self.calculate_twitter_fit_score(hover_craft)
    return if hover_craft.twitter_crafted   # already crafted
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
    return if hover_craft.yelp_crafted   # already crafted
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
    return if hover_craft.facebook_crafted   # already crafted
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
    return if hover_craft.website_crafted    # already crafted
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

  def self.twitter_craft_for(hover_craft)
    {
      web_craft_id: hover_craft.twitter_id,
      name: hover_craft.twitter_name,
      username: hover_craft.twitter_screen_name,
      href: hover_craft.twitter_href,
      address: hover_craft.twitter_address,
      description: hover_craft.twitter_profile['description'],
      is_protected: hover_craft.twitter_profile['is_protected'],
      followers_count: hover_craft.twitter_profile['followers_count'],
      statuses_count: hover_craft.twitter_profile['statuses_count'],
      lang: hover_craft.twitter_profile['lang'],
      profile_background_color: hover_craft.twitter_profile['profile_background_color'],
      profile_background_image_url_https: hover_craft.twitter_profile['profile_background_image_url_https'],
      profile_background_tile: hover_craft.twitter_profile['profile_background_tile'],
      profile_image_url_https: hover_craft.twitter_profile['profile_image_url_https'],
      profile_use_background_image: hover_craft.twitter_profile['profile_use_background_image'],

      #twitter_account_created_at: hover_craft.twitter_profile['twitter_account_created_at'],
      #friends_count: hover_craft.twitter_profile['friends_count'],
      #listed_count: hover_craft.twitter_profile['listed_count'],
      #favourites_count: hover_craft.twitter_profile['favourites_count'],
      #profile_link_color: hover_craft.twitter_profile['profile_link_color'],
      #profile_sidebar_border_color: hover_craft.twitter_profile['profile_sidebar_border_color'],
      #profile_sidebar_fill_color: hover_craft.twitter_profile['profile_sidebar_fill_color'],
      #profile_text_color: hover_craft.twitter_profile['profile_text_color'],
    }
  end

  def self.yelp_craft_for(hover_craft)
    {
      web_craft_id: hover_craft.yelp_id,
      name: hover_craft.yelp_name,
      href: hover_craft.yelp_href,
      #address: hover_craft.yelp_address,
      # description: hover_craft.yelp_profile['description'],
      # phone: hover_craft.yelp_profile['phone'],
      # image_url: hover_craft.yelp_profile['image_url'],
      # categories: hover_craft.yelp_profile['categories']
    }
  end

  def self.facebook_craft_for(hover_craft)
    {
      web_craft_id: hover_craft.facebook_id,
      name: hover_craft.facebook_name,
      username: hover_craft.facebook_profile['username'],
      href: hover_craft.facebook_href,
      likes: hover_craft.facebook_profile['likes'],
      first_name: hover_craft.facebook_profile['first_name'],
      last_name: hover_craft.facebook_profile['last_name'],
      about: hover_craft.facebook_profile['about'], # description
    }
  end

  def self.website_craft_for(hover_craft)
    {
      web_craft_id: hover_craft.website_url,
      name: hover_craft.website_name,
    }
  end

end