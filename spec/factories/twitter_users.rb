# To Create Twitter::User instances
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


# To Create TwitterUser instances
FactoryGirl.define do
  factory :twitter_user do
    twitter_id  { generate :twitter_id }
    name        { generate :twitter_name }
    screen_name { name.squish.gsub(/\s+/, "_") }
  end
end