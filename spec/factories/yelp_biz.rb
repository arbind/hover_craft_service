def create_yelp_biz(biz_name)
  {
    id:   "#{biz_name.underscore}",
    name: biz_name,
    url:  "http://yelp.com/#{biz_name.underscore}"
  }
end


def create_yelp_results(*biz_names)
  biz_list = biz_names.map{|biz_name| create_yelp_biz(biz_name)}
  { 'businesses'=>biz_list }
end