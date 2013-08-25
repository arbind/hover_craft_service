class FacebookHandler
  def self.populate_facebook_craft(hover_craft)
    return if hover_craft.facebook_craft or hover_craft.facebook_name
    facebook_href = facebook_user = nil
    if hover_craft.facebook_href and !hover_craft.facebook_id
      facebook_href = hover_craft.facebook_href
    elsif :facebook.eql? Web.provider_for_href hover_craft.twitter_website_url
      facebook_href = hover_craft.twitter_website_url
    elsif :facebook.eql? Web.provider_for_href hover_craft.yelp_website_url
      facebook_href = hover_craft.yelp_website_url
    elsif hover_craft.website_profile and hover_craft.website_profile[:facebook_links].present?
      facebook_href = hover_craft.website_profile[:facebook_links].first
    end
    facebook_user = FacebookApi.user_for_facebook_href facebook_href if facebook_href
    if facebook_user
      hover_craft.update_attributes(facebook_user.to_hover_craft)
      WorkLauncher.launch :populate_hover_craft, hover_craft
    end
  end
end