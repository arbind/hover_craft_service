class YelpApi
  include Singleton
  attr_reader :yelp_client
  V2_MAX_RESULTS_LIMIT = 20
  V2_MAX_RADIUS_FILTER = 40000 #in meters (~25 miles)

  def self.service() self end

  def initialize() @yelp_client = Yelp::Client.new end

  def self.yelp() instance.yelp_client end

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
    response = yelp.search(request)
    businesses = response["businesses"] if response
    YelpBiz.new businesses.first if businesses and businesses.any?
  end

private
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

  # YelpProfile
  # HashObject that makes it easy to work with responses from the Yelp gem
  class YelpBiz < HashObject
    def to_hover_craft
      {
        yelp_id:          id,
        yelp_name:        name,
        yelp_href:        url,
        yelp_website_url: find_website_url,
        yelp_address:     construct_address,
        yelp_categories:  categories,
      }
    end

    def find_website_url
      return @website_url if @website_url
      biz_url = Web.site(url).select_first('#bizUrl a')
      return "" unless biz_url
      @website_url = biz_url.content if biz_url
      doc_links = []
      doc = Nokogiri::HTML(open url,  'User-Agent' => 'ruby')
      doc.css('#bizUrl a').each { |link| doc_links << link.content }
      @website_url = doc_links.first
    end

    def construct_address
      return nil unless location
      display_address_tokens = location["display_address"]
      return nil unless display_address_tokens and display_address_tokens.any?
      display_address_tokens.join(", ")
    end
  end

end