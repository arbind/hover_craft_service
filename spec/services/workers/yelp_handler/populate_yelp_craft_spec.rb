require 'spec_helper'
require 'sidekiq/testing'

describe :populate_yelp_craft do
  let (:yelp_results) { create_yelp_results *biz_list }
  let (:biz_list)     { [ biz_name ]}
  let (:biz_name)     { 'My Craft'}
  let (:yelp_link)    { yelp_results['businesses'].first[:url] }

  let (:yelp_client)  { double search: yelp_results }

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
    it 'schedules :yelp_scan_for_link job to get the yelp_website_url' do
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
    let (:hover_craft)  { create :hover_craft, :streamer, :twitter, :yelp }
    it_behaves_like 'it skips processing'
  end

  context 'given a yelp craft was already crafted' do
    let (:hover_craft)  { create :hover_craft, :streamer, :twitter, yelp_craft: true }
    it_behaves_like 'it skips processing'
  end

  context 'given a twitter_craft and a streamer address' do    # search for yelp biz by name and address limit to 1 (take the first one)
    let (:hover_craft)  { create :hover_craft, :streamer, :twitter  }
    context 'when a yelp biz is found' do
      it_behaves_like 'it found a yelp craft'
    end
    context 'when a yelp biz does not exist near the streamers address' do
      let (:biz_list)   { [ ] }
      it_behaves_like 'it did not find any yelp craft'
    end
  end

  context 'given a yelp_href but no yelp_id' do
    let (:hover_craft)  { create :hover_craft, yelp_href: yelp_link }
    it_behaves_like 'it found a yelp craft'
  end

  context 'given a website_craft that has a link to a yelp biz' do
    let (:hover_craft)  { create :hover_craft, website_profile: {yelp_links: [yelp_link]},  website_url: 'http://my-home-page.com' }
    it_behaves_like 'it found a yelp craft'
  end

  context 'given a twitter_website_url that points to a yelp_href' do
    let (:hover_craft)  { create :hover_craft, :twitter, twitter_website_url: yelp_link  }
    it_behaves_like 'it found a yelp craft'
  end

  context 'given a facebook_website_url that points to a yelp_href' do
    let (:hover_craft)  { create :hover_craft, :facebook, facebook_website_url: yelp_link  }
    it_behaves_like 'it found a yelp craft'
  end

end