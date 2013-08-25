def create_twitter_user(id=nil)
  user_info= {
    id:           id || generate(:twitter_id),
    id_str:       "#{id}",
    name:         "Prince the #{id}th",
    screen_name:  "tweeter-#{id}"
  }
  Twitter::User.new user_info
end

def create_twitter_users(ids)
  ids.map{ |id| create_twitter_user(id) }
end