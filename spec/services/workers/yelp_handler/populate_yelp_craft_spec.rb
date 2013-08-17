require 'spec_helper'
require 'sidekiq/testing'

describe :populate_yelp_craft do
  let (:yelp_results) { create_yelp_results *biz_list }
  let (:biz_list)     { [ biz_name ]}
  let (:biz_name)     { 'My Craft'}

  let (:yelp_client)  { double search: yelp_results }

  let (:address)      { 'Santa Monica, CA'}
  let (:streamer)     { create :tweet_streamer, address: address, name: 'streamer'}
  let (:hover_craft)  { create :hover_craft, tweet_streamer: streamer, twitter_name: biz_name, twitter_id: 123 }

  before :each do
    Yelp::Client.stub(:new).and_return yelp_client
  end

  after :each do
    YelpApi.instance.yelp_client = nil
  end

  shared_examples_for 'it found a yelp craft' do
    it 'makes an api call' do
      expect(yelp_client).to receive(:search).once
      YelpHandler.populate_yelp_craft(hover_craft)
    end
    it 'populates the yelp_craft' do
      expect{
        YelpHandler.populate_yelp_craft(hover_craft)
      }.to change(hover_craft, :yelp_name).to(biz_name)
    end
    it 'schedules :scan_for_links job to get the yelp_website_url' do
      expect {
        YelpHandler.populate_yelp_craft(hover_craft)
      }.to change(YelpScanForLink.jobs, :size).by(1)
    end
  end

  shared_examples_for 'it did not find any yelp craft' do
    it 'makes an api call' do
      expect(yelp_client).to receive(:search).once
      YelpHandler.populate_yelp_craft(hover_craft)
    end
    it 'does not populate the yelp_craft' do
      expect{
        YelpHandler.populate_yelp_craft(hover_craft)
      }.not_to change(hover_craft, :yelp_name)
    end
    it 'does not schedule :scan_for_links job' do
      expect {
        YelpHandler.populate_yelp_craft(hover_craft)
      }.not_to change(YelpScanForLink.jobs, :size)
    end
  end

  shared_examples_for 'it skips processing' do
    it 'does not makes an api call' do
      expect(yelp_client).to receive(:search).never
      YelpHandler.populate_yelp_craft(hover_craft)
    end
    it 'does not populate the yelp_craft' do
      expect{
        YelpHandler.populate_yelp_craft(hover_craft)
      }.not_to change(hover_craft, :yelp_name)
    end
    it 'does not schedule :scan_for_links job' do
      expect {
        YelpHandler.populate_yelp_craft(hover_craft)
      }.not_to change(YelpScanForLink.jobs, :size)
    end
  end

  context 'given a yelp craft already exists' do
    let (:hover_craft)  { create :hover_craft, tweet_streamer: streamer, twitter_name: biz_name, twitter_id: 123, yelp_name: biz_name }
    it_behaves_like 'it skips processing'
  end

  context 'given a yelp craft was already crafted' do
    let (:hover_craft)  { create :hover_craft, tweet_streamer: streamer, twitter_name: biz_name, twitter_id: 123, yelp_craft: true}
    it_behaves_like 'it skips processing'
  end

  context 'given a twitter_craft and a streamer address' do
    # search for yelp biz by name and address limit to 1 (take the first one)
    let (:address)      { 'Santa Monica, CA'}
    let (:streamer)     { create :tweet_streamer, address: address, name: 'streamer'}
    let (:hover_craft)  { create :hover_craft, tweet_streamer: streamer, twitter_name: biz_name, twitter_id: 123 }
    context 'when a yelp biz is found' do
      it_behaves_like 'it found a yelp craft'
    end
    context 'when a yelp biz does not exist near the streamers address' do
      let (:biz_list)   { [ ] }
      it_behaves_like 'it did not find any yelp craft'
    end
  end

  context 'given a yelp_href but no yelp_id' do
    let (:yelp_link)    { "http://yelp.com/#{biz_name.underscore}" }
    let (:hover_craft)  { create :hover_craft, yelp_href: yelp_link }
    it_behaves_like 'it found a yelp craft'
  end

  context 'given a website_craft that has a link to a yelp biz' do
    # parse out yelp id and find biz by id
    # let (:hover_craft)  { create :hover_craft, website_links: [yelp_link],  website_url: 'http://my-home-page.com' }
    # it_behaves_like 'it found a yelp craft'
    # it 'calls the YelpApi.biz'
  end

  context 'given a yelp craft is already populated' do
    # do not do anything if (yelp_id and yelp_name) (does not call yelp api)
    # let (:hover_craft)  { create :hover_craft, yelp_id: '123', yelp_name: biz_name }
    # it 'does not modify the hover craft' do
    #   # YelpHandler.populate_yelp_craft(hover_craft)
    # end
  end

end