def create_facebook_user(username)
  {
    "id"=>"91451508751",
    "username"=>username,
    "website"=>"http://www.#{username}.com",
    "name"=>"Nom Nom Truck",
    "likes"=>88,
    "phone"=>"(555) 123-4567",
    "link"=>"http://www.facebook.com/#{username}",
    "culinary_team"=>"Jen Zen",
    "description"=>"Munchy treats from #{username}",
    "location"=>{"street"=>"", "city"=>"San Francisco", "state"=>"CA", "country"=>"United States", "zip"=>""},
  }
end

def create_facebook_users(usernames)
  usernames.map{ |username| create_facebook_user(username) }
end