def create_twitter_user(id)
  {
    id_str: "#{id}",
    name: "Prince the #{id}th",
    screen_name: "tweeter-#{id}"
  }
end

def create_twitter_users(ids)
  ids.map{ |id| create_twitter_user(id) }
end