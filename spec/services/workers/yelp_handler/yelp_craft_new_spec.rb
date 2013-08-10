describe :yelp_craft_new_spec do
  it 'identifies a potential yelp_craft for a hover craft'
  it 'populates the yelp_craft for a hover craft'
  it 'schedules a ResolveUrl job for the yelp_website_url'

  context 'given a twitter craft and streamer' do
    it 'uses the twitter_name and streamer location to find a biz' do

    end
  end

  context 'given an identified yelp craft' do
    it 'sets the yelp_id on the hover craft'
    it 'schedules a YelpCraftCreate'
  end
  context 'given no potential' do
    it 'sets the yelp_id to empty string'
    it 'does not schedule a YelpCraftCreate'
  end
end