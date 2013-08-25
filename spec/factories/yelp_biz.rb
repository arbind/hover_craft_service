def create_yelp_biz(biz_name)
  yelp_id = biz_name.downcase.squish.gsub(/\s+/, "_")
  {
    id:   "#{yelp_id}",
    name: biz_name,
    url:  "http://yelp.com/#{yelp_id}"
  }
end


def create_yelp_results(*biz_names)
  biz_list = biz_names.map{|biz_name| create_yelp_biz(biz_name)}
  { 'businesses'=>biz_list }
end