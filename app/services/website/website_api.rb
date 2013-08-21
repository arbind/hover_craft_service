class WebsiteApi

  def self.service() self end

  def self.website_info(url)
    site = Web.new url
    info =  {
      url: url,
      title: site.title
    }
    info.merge! site.provider_links

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
        :yelp_links,
        :twitter_links,
        :facebook_links
      ]
    end

  private
    def to_profile
      to_hash.select {|k,v| WebsiteProfile.profile_attributes.include? k.to_sym}
    end
  end

end