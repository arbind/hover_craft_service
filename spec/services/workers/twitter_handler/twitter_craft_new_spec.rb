describe :twitter_craft_new_spec do
  it 'identifies a potential twitter_craft for a hover craft'
  context 'given an identified twitter craft' do
    it 'sets the twitter_screen_name on the hover craft'
    it 'schedules a TwitterCraftCreate'
  end
  context 'given no potential' do
    it 'sets the twitter_id to empty string'
    it 'does not schedule a TwitterCraftCreate'
  end
end