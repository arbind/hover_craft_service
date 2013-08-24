class FacebookApi
  include Singleton
  attr_accessor :facebook_client

  def self.service() self end

  def facebook_client() @facebook_client ||= Koala::Facebook::API.new end
  def self.facebook_client() instance.facebook_client end

  def self.user(id)
    user = facebook_client.get_object(id)
    FacebookProfile.new user if user
  rescue
    nil
  end

  def self.user_for_facebook_href(href)
    facebook_id = id_from_href href
    user facebook_id
  end

  def self.id_from_href(href)
    return nil if href.nil?
    username = nil
    begin
      url = href.to_href.downcase.split('?')[0] # strip off query params
      url = url.split('#')[0] # strip off hash tag params
      u = URI.parse(url)
      return nil unless ['www.facebook.com', 'facebook.com'].include?(u.host)
      flat = url.gsub(/\/\//, '')
      tokens = flat.split('/')
      return nil unless tokens.present?
      case tokens.size
        when 2 # facebook.com/page_id  <- usr page_id as username
          username = tokens[1] if id_is_valid?(tokens[1])
        when 4 # facebook.com/pages/PageName/page_id  <- use real page id as username
          pages = tokens[1].downcase
          page_id = tokens[2] # sometimes page_id works,
          page_id = tokens[3] if  web_fetch(page_id).nil? # sometimes PageName works
          username = page_id if ( "pages" == pages and id_is_valid?(page_id) )
        when 5 # facebook.com/pages/city-ST/PageName/some_id  <- use real PageName as username
          pages = tokens[1].downcase
          username = tokens[3] if ( 'pages' == pages and id_is_valid?(tokens[3]) )
        else
          # username = nil
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
    username
  end

  def self.id_is_valid?(id) valid_username?(id) end
  def self.valid_username?(username)
    return false if username.nil?
    username_match = username.match /^[\S]+$/i
    username_match.present? and username_match.to_s == username
  end

  # FacebookProfile
  # HashObject makes it easy to work with responses from the koala facebook graph gem
  class FacebookProfile < HashObject
    def initialize(hash)
      super
      self['website']= self.website.strip.split(' ').first.to_href if self.website
    end

    def to_hover_craft
      {
          facebook_id:           id,
          facebook_name:         name,
          facebook_href:         link,
          facebook_username:     username,
          facebook_website_url:  website,
          facebook_profile:      to_profile
      }
    end

  private
    def to_profile
      to_hash.select {|k,v| FacebookProfile.profile_attributes.include? k.to_sym}
    end
    def self.profile_attributes
      [
        :likes,
        #:description,
        :culinary_team,
        :location,
        :phone,
        :link,
      ]
    end
  end
end
