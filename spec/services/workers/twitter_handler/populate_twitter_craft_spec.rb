require 'spec_helper'
require 'sidekiq/testing'

describe :populate_twitter_craft do

  let (:screen_name)    { generate :twitter_screen_name }
  let (:twitter_user)   { create_twitter_user }
  let (:twitter_link)   { TwitterApi.twitter_href_for_screen_name screen_name }
  let (:twitter_client) { Twitter }
  let (:client_options) { {} }
  before do
    Twitter.stub(:user).with(screen_name, client_options).and_return twitter_user
  end
  shared_examples_for 'it found a twitter craft' do
    it 'makes an api call' do
      expect(twitter_client).to receive(:user).once
      TwitterHandler.populate_twitter_craft(hover_craft)
    end
    it 'populates the twitter_craft' do
      expect{
        TwitterHandler.populate_twitter_craft(hover_craft)
      }.to change(hover_craft, :twitter_name).to(twitter_user['name'])
    end
    it 'schedules :populate_hover_craft' do
      expect {
        TwitterHandler.populate_twitter_craft(hover_craft)
      }.to change(PopulateHoverCraft.jobs, :size).by(1)
    end
  end

  shared_examples_for 'it did not find any twitter craft' do
    it 'makes an api call' do
      expect(twitter_client).to receive(:user).once
      TwitterHandler.populate_twitter_craft(hover_craft)
    end
    it 'does not populate the twitter_craft' do
      expect{
        TwitterHandler.populate_twitter_craft(hover_craft)
      }.not_to change(hover_craft, :twitter_name)
    end
    it 'does not schedule :populate_hover_craft' do
      expect {
        TwitterHandler.populate_twitter_craft(hover_craft)
      }.to change(PopulateHoverCraft.jobs, :size).by(0)
    end
  end

  shared_examples_for 'it skips processing' do
    it 'does not makes an api call' do
      expect(twitter_client).to receive(:user).never
      TwitterHandler.populate_twitter_craft(hover_craft)
    end
    it 'does not populate the twitter_craft' do
      expect{
        TwitterHandler.populate_twitter_craft(hover_craft)
      }.not_to change(hover_craft, :twitter_name)
    end
    it 'does not schedule :populate_hover_craft' do
      expect {
        TwitterHandler.populate_twitter_craft(hover_craft)
      }.to change(PopulateHoverCraft.jobs, :size).by(0)
    end
  end

  context 'given a twitter craft already exists' do
    let (:hover_craft)  { create :hover_craft, :twitter }
    it_behaves_like 'it skips processing'
  end

  context 'given a twitter craft was already crafted' do
    let (:hover_craft)  { create :hover_craft, twitter_craft: true }
    it_behaves_like 'it skips processing'
  end

  context 'given a twitter_screen_name and no twitter_id' do
    let (:hover_craft) { create :hover_craft, twitter_screen_name: screen_name }
    it_behaves_like 'it found a twitter craft'
  end

  context 'given a facebook_website_url that points to valid twitter account' do
    let (:hover_craft)  { create :hover_craft, :facebook, facebook_website_url: twitter_link }
    it_behaves_like 'it found a twitter craft'
  end

  context 'given a yelp_website_url that points to valid twitter account' do
    let (:hover_craft)  { create :hover_craft, :yelp, yelp_website_url: twitter_link }
    it_behaves_like 'it found a twitter craft'
  end

  context 'given a website_craft that has a link to a twitter' do
    let (:hover_craft)  { create :hover_craft, website_profile: {twitter_links: [twitter_link]},  website_url: 'http://my-home-page.com' }
    it_behaves_like 'it found a twitter craft'
  end

end