class WebsiteApi

  def self.service() self end

  def self.website_info(url)
    site = Web.new url
    yelp_links = site.links 'yelp'
    twitter_links = site.links 'twitter'
    facebook_links = site.links 'facebook'
    info =  {
      url: url,
      title: site.title
    }
    info[:yelp_link] = yelp_links.first if yelp_links.any?
    info[:twitter_link] = twitter_links.first if twitter_links.any?
    info[:facebook_link] = facebook_links.first if facebook_links.any?

    WebsiteProfile.new info
  end

  # WebsiteProfile
  class WebsiteProfile < HashObject
    def to_hover_craft
      {
        website_url:          url,
        website_name:         title,
        website_profile:      to_profile
      }
    end


    def self.profile_attributes
      [
        :yelp_link,
        :twitter_link,
        :facebook_link
      ]
    end

  private
    def to_profile
      to_hash.select {|k,v| WebsiteProfile.profile_attributes.include? k.to_sym}
    end
  end

end