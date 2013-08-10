def create_twitter_profile(id)
  TwitterApi::TwitterProfile.new({
    id_str: "#{id}",
    name: "Prince the #{id}th",
    screen_name: "tweeter-#{id}"
  })
end

def create_twitter_profiles(ids)
  ids.map{ |id| create_twitter_profile(id) }
end