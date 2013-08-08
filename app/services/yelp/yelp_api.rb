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
end