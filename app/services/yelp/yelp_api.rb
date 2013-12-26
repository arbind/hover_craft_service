class YelpApi
  include Singleton
  attr_accessor :yelp_client
  V2_MAX_RESULTS_LIMIT = 20
  V2_MAX_RADIUS_FILTER = 40000 #in meters (~25 miles)

  # Yelp V1 and V2 APIs
  # V1 API id deprecated, but it is still useful with phone number search and neighborhood lookup

  def self.service() self end

  def yelp_client() @yelp_client ||= Yelp::Client.new end

  def self.yelp() instance.yelp_client end

  def self.biz_for_id(yelp_id)
    query = v2({yelp_business_id: yelp_id})
    request = Yelp::V2::Business::Request::Id.new(query)
    biz = yelp_search(request)
    YelpBiz.new biz if biz
  end

  def self.website_for_id(yelp_id)
    yelp_href = "http://www.yelp.com/biz/#{URI::encode yelp_id}"
    link = Web.site(yelp_href).select_first('#bizUrl a')
    biz_url = link.content.strip.to_href if link and link.content
  end

  def self.biz_for_yelp_href (href)
    yelp_id = yelp_id_from_href href
    biz_for_id yelp_id
  end

  def self.biz_for_name(name, place, radius=V2_MAX_RADIUS_FILTER)
    query = {
      term: name,
      city: place,
      radius_filter: radius,
      offset: 0,
      limit: 1
    }
    query    = v2(query)
    request  = Yelp::V2::Search::Request::Location.new(query)
    response = yelp_search(request)
    businesses = response["businesses"] if response
    YelpBiz.new businesses.first if businesses and businesses.any?
  end

  def self.biz_for_phone_number(number)
    # there is no phone number search in v2, lets use v1
    response = self.v1_biz_for_phone_number(number) # a v1 response
    # v1 and v2 yelp id's do not match
    # Don't want to save same biz in two times with different yelp_ids!
    # We can use the v2 search with v1 yelp id to get the correct v2 version
    v1_yelp_id = response['id'] if response # v1 yelp_id = '53UyLtU4F7seRkPfL6TY6Q'
    response = biz_for_id(v1_yelp_id) if v1_yelp_id # v2 yelp_id = 'grill-em-all-los-angeles'
    response
  end

  def self.yelp_id_from_href(href)
    return nil if href.nil?
    listing_id = nil
    begin
      url = Web.strip_href href.downcase
      u = URI.parse(url)
      u = URI.parse("http://#{url}") if u.host.nil?
      return nil unless ['www.yelp.com', 'yelp.com'].include?(u.host)
      flat = url.gsub(/\/\//, '')
      tokens = flat.split('/')
      case tokens.size
        when 3
          biz = tokens[1]
          listing_id = tokens[2] if ("biz" == biz)
        else
          # listing_id = nil
      end
    rescue Exception => e
      Rails.logger.error "Faild to get yelp id from #{href}: #{e.message}"
    end
    listing_id
  end


  def self.search(term, place, page=1, radius=V2_MAX_RADIUS_FILTER)
    offset = V2_MAX_RESULTS_LIMIT*(page-1) # 1 + this ?
    query = {
      term: term,
      # categories: ['streetvendors', 'foodstands'],
      city: place,
      radius_filter: radius,
      offset: offset,
      limit: V2_MAX_RESULTS_LIMIT
    }
    query = v2(query)
    request = Yelp::V2::Search::Request::Location.new(query)
    response = yelp_search(request)
  end

  def self.search_for_term(term, location, radius_filter=10000) # API v2 specifies radius_filter (not radius) and is in meters (max 40000)
    if location.geo_point.present?
      query = { term: term, radius_filter: radius_filter }.merge(location.geo_point)
      puts query
      query = v2(query)
      request = Yelp::V2::Search::Request::GeoPoint.new(query)
    elsif location.geo_boundary
      query = { term: term, radius_filter: radius_filter }.merge(location.geo_boundary)
      puts query
      query = v2(query)
      request = Yelp::V2::Search::Request::BoundingBox.new(query)
    else
      # query = { term: term, radius_filter: radius_filter, location: location.address_to_s }
      query = { term: term, radius_filter: radius_filter}.merge(location.mailing_address)
      puts query
      query = v2(query)
      request = Yelp::V2::Search::Request::Location.new(query)
    end
    response = yelp_search(request)
  end

  def self.search_for_category(category_array, location, radius_filter=10000)
    # be sureto use the category code (for example 'discgolf', not 'Disc Golf'):
    # category codes: http://www.yelp.com/developers/documentation/category_list
    if location.latitude
      query = { category: category_array, radius_filter: radius_filter }.merge(location.location.geo_point)
      query = v2(query)
      request = Yelp::V2::Search::Request::GeoPoint.new(query)
    elsif location.top_left_longitude
      query = { category: category_array, radius_filter: radius_filter }.merge(location.bounding_box)
      query = v2(query)
      request = Yelp::V2::Search::Request::BoundingBox.new(query)
    else
      # query = { category: category_array, radius_filter: radius_filter, location: location.address_to_s }
      query = { category: category_array, radius_filter: radius_filter}.merge(location.mailing_address)
      query = v2(query)
      request = Yelp::V2::Search::Request::Location.new(query)
    end
    response = yelp_search(request)
  end

private
  def self.yelp_search(request)
    response = yelp.search(request)
    raise YelpError.new(response) if error?(response)
    response
  end

  def self.error?(response)
    response['error'].present?
  end

  def self.v1(query={})
    {
      yws_id: SECRET::YELP::V1::YWS_ID
    }.merge query
  end

  def self.v2(query={})
    {
      consumer_key:     SECRET::YELP::V2::CONSUMER_KEY,
      consumer_secret:  SECRET::YELP::V2::CONSUMER_SECRET,
      token:            SECRET::YELP::V2::TOKEN,
      token_secret:     SECRET::YELP::V2::TOKEN_SECRET,
    }.merge query
  end

  # keep V1 API private since it is deprecated
  def self.v1_biz_for_phone_number(number)
    response = v1_search_for_phone_number(number)
    biz_list = biz_list_from_response(response)
    return nil if (biz_list.nil? or biz_list.size.zero?)
    biz_list.first
  end

  # YelpProfile
  # HashObject that makes it easy to work with responses from the Yelp gem
  class YelpBiz < HashObject
    def to_hover_craft
      {
        yelp_id:          id,
        yelp_name:        name,
        yelp_href:        url,
        yelp_address:     construct_address,
        yelp_categories:  categories,
      }
    end

  private
    def construct_address
      return nil unless location
      display_address_tokens = location["display_address"]
      return nil unless display_address_tokens and display_address_tokens.any?
      display_address_tokens.join(", ")
    end
  end

  # Error response when rate limit is exceeded:
  # {"error"=>{"text"=>"Exceeded max daily requests", "id"=>"EXCEEDED_REQS"}}
  class YelpError < StandardError
    def initialize(api_response)
      super "Yelp API: #{api_response['error']['text']}"
    end
  end
end