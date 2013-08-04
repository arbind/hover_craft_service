FactoryGirl.define do
  factory :hover_craft do

    factory :twitter_hover_craft do
      twitter_id            { FactoryGirl.generate :twitter_id }
      twitter_name          { FactoryGirl.generate :name }
      twitter_screen_name   { FactoryGirl.generate :screen_name }
    end
  end
end