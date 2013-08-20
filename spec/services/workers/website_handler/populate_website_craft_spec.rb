require 'spec_helper'
require 'sidekiq/testing'
describe :populate_website_craft do

  shared_examples_for 'it found a website craft' do
    it 'populates the website_craft' do
      expect{
        WebsiteHandler.populate_website_craft(hover_craft)
      }.to change(hover_craft, :website_url).to(final_url)
    end
    it 'finds links to yelp, facebook and twitter on the website' do
      expect(true).to be_false
    end
    context 'given missing web crafts' do
      it 'schedules :populate_hover_craft to fill in any missing web crafts' do
        expect {
          WebsiteHandler.populate_website_craft(hover_craft)
        }.to change(PopulateHoverCraft.jobs, :size).by(1)
      end
    end
    context 'given no missing web crafts' do
      let (:hover_craft) { create :no_website_hover_craft}
      it 'does not schedule :populate_hover_craft' do
        expect {
          WebsiteHandler.populate_website_craft(hover_craft)
        }.to change(PopulateHoverCraft.jobs, :size).by(0)
      end
    end
  end

  shared_examples_for "it doesn't change anything" do
    it 'does not populate the website_craft' do
      expect{
        WebsiteHandler.populate_website_craft(hover_craft)
      }.not_to change(hover_craft, :website_url)
    end
    it 'does not schedule :populate_hover_craft job' do
      expect {
        WebsiteHandler.populate_website_craft(hover_craft)
      }.not_to change(PopulateHoverCraft.jobs, :size)
    end
  end

  let (:final_url) { 'http://my-site.com' }
  let!(:double)      { Web.double(:final_url_for).and_return(final_url)}

  context 'given a website craft already exists' do
    let (:hover_craft)  { create :hover_craft, :streamer, :twitter, :yelp }
    it_behaves_like "it doesn't change anything"
  end

  context 'given a website craft was already crafted' do
    let (:hover_craft)  { create :hover_craft, :streamer, :twitter, yelp_craft: true }
    it_behaves_like "it doesn't change anything"
  end

  context 'given a streamer and a twitter_website_url' do
    let (:hover_craft)  { create :hover_craft, :streamer, :twitter, twitter_website_url: final_url  }
    context 'for a valid website' do
      it_behaves_like 'it found a website craft'
    end
    context 'for an invalid website' do
      let (:final_url) { "" }
      it_behaves_like "it doesn't change anything"
    end
  end

  context 'given a facebook_website_url' do
    let (:hover_craft)  { create :hover_craft, :facebook, facebook_website_url: final_url  }
    context 'for a valid website' do
      it_behaves_like 'it found a website craft'
    end
    context 'for an invalid website' do
      let (:final_url) { "" }
      it_behaves_like "it doesn't change anything"
    end
  end

  context 'given a yelp_website_url' do
    let (:hover_craft)  { create :hover_craft, :yelp, yelp_website_url: final_url  }
    context 'for a valid website' do
      it_behaves_like 'it found a website craft'
    end
    context 'for an invalid website' do
      let (:final_url) { "" }
      it_behaves_like "it doesn't change anything"
    end
  end

end