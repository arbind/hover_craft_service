require 'spec_helper'
require 'sidekiq/testing'

describe :populate_facebook_craft do
  let (:facebook_profile) { create_facebook_user username }
  let (:username)         { 'MyCraft'}
  let (:facebook_client)  { double get_object: facebook_profile }
  let (:facebook_link)    { facebook_profile['link'] }

  before :each do
    Koala::Facebook::API.stub(:new).and_return facebook_client
  end

  after :each do
    FacebookApi.instance.facebook_client = nil
  end

  shared_examples_for 'it found a facebook craft' do
    it 'makes an api call' do
      expect(facebook_client).to receive(:get_object).once
      FacebookHandler.populate_facebook_craft(hover_craft)
    end
    it 'populates the facebook_craft' do
      expect{
        FacebookHandler.populate_facebook_craft(hover_craft)
      }.to change(hover_craft, :facebook_name).to(facebook_profile['name'])
    end
    it 'resolves facebook_website_url'
    it 'schedules PopulateHoverCraft job' do
      new_job_data = PopulateHoverCraft .work_data hover_craft
      PopulateHoverCraft.should_receive(:schedule).with new_job_data
      FacebookHandler.populate_facebook_craft(hover_craft)
    end
  end

  shared_examples_for 'it did not find any facebook craft' do
    it 'makes an api call' do
      expect(facebook_client).to receive(:get_object).once
      FacebookHandler.populate_facebook_craft(hover_craft)
    end
    it 'does not populate the facebook_craft' do
      expect{
        FacebookHandler.populate_facebook_craft(hover_craft)
      }.not_to change(hover_craft, :facebook_name)
    end
    it 'does not schedule :populate_hover_craft' do
      expect {
        FacebookHandler.populate_facebook_craft(hover_craft)
      }.to change(PopulateHoverCraft.jobs, :size).by(0)
    end
  end

  shared_examples_for 'it skips processing' do
    it 'does not makes an api call' do
      expect(facebook_client).to receive(:get_object).never
      FacebookHandler.populate_facebook_craft(hover_craft)
    end
    it 'does not populate the facebook_craft' do
      expect{
        FacebookHandler.populate_facebook_craft(hover_craft)
      }.not_to change(hover_craft, :facebook_name)
    end
    it 'does not schedule :populate_hover_craft' do
      expect {
        FacebookHandler.populate_facebook_craft(hover_craft)
      }.to change(PopulateHoverCraft.jobs, :size).by(0)
    end
  end

  context 'given a facebook craft already exists' do
    let (:hover_craft)  { create :hover_craft, :facebook }
    it_behaves_like 'it skips processing'
  end

  context 'given a facebook craft was already crafted' do
    let (:hover_craft)  { create :hover_craft, facebook_craft: true }
    it_behaves_like 'it skips processing'
  end

  context 'given a facebook_href but no facebook_id' do
    let (:hover_craft)  { create :hover_craft, facebook_href: facebook_link, facebook_id: nil }
    it_behaves_like 'it found a facebook craft'
  end

  context 'given a twitter_website_url that points to valid facebook account' do
    let (:hover_craft)  { create :hover_craft, :twitter, twitter_website_url: facebook_link }
    it_behaves_like 'it found a facebook craft'
  end

  context 'given a yelp_website_url that points to valid facebook account' do
    let (:hover_craft)  { create :hover_craft, :yelp, yelp_website_url: facebook_link }
    it_behaves_like 'it found a facebook craft'
  end

  context 'given a website_craft that has a link to a facebook' do
    let (:hover_craft)  { create :hover_craft, website_profile: {'facebook_links' => [facebook_link]},  website_url: 'http://my-home-page.com' }
    it_behaves_like 'it found a facebook craft'
  end

  context 'when a facebook account does not exist' do
    let (:facebook_profile)   { nil }
    let (:facebook_link)    { "http://facebook.com/no-such-user" }
    let (:hover_craft)  { create :hover_craft, facebook_href: facebook_link }
    it_behaves_like 'it did not find any facebook craft'
  end
end