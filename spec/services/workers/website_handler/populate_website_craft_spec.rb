require 'spec_helper'
require 'sidekiq/testing'
describe :populate_website_craft do
  let!(:mock_web)           { Web.any_instance.stub(:document).and_return(mock_document) }
  let!(:mock_final_url_for) { Web.stub(:final_url_for).and_return(final_url)}
  let (:final_url)          { 'http://my-site.com' }
  let (:title)              { 'My Biz' }
  let (:yelp_href)          { 'http://yelp.com/biz/my-biz'}
  let (:twitter_href)       { 'http://twitter.com/my_biz'}
  let (:facebook_href)      { 'http://facebook.com/my.biz'}
  let (:mock_document)      { Nokogiri::HTML "
    <html>
      <head>
      <title>#{title}</title>
      </head>
      <body>
        <h1>#{title}</h1>
        <a href='#{yelp_href}'>yelper</a>
        <a href='#{twitter_href}'>t</a>
        <a href='#{facebook_href}'>fb</a>
      </body>
    </html>
  "}

  shared_examples_for 'it found a website craft' do
    it 'populates the website_craft' do
      WebsiteHandler.populate_website_craft(hover_craft)
      expect(hover_craft.website_url).to eq final_url
      expect(hover_craft.website_name).to eq title
    end
    it 'finds links to yelp, facebook and twitter on the website' do
      WebsiteHandler.populate_website_craft(hover_craft)
      website_profile = hover_craft.website_profile
      expect(website_profile[:yelp_links]).to eq [yelp_href]
      expect(website_profile[:twitter_links]).to eq [twitter_href]
      expect(website_profile[:facebook_links]).to eq [facebook_href]
    end
    it 'schedules :populate_hover_craft' do
      expect {
        WebsiteHandler.populate_website_craft(hover_craft)
      }.to change(PopulateHoverCraft.jobs, :size).by(1)
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

  context 'given a website craft already exists' do
    let (:hover_craft)  { build :complete_hover_craft}
    it_behaves_like "it doesn't change anything"
  end

  context 'given a website craft was already crafted' do
    let (:hover_craft)  { build :no_website_hover_craft, website_crafted: true }
    it_behaves_like "it doesn't change anything"
  end

  context 'given a streamer and a twitter_craft' do
    let (:final_url)    { hover_craft.twitter_website_url }
    let (:hover_craft)  { build :hover_craft, :streamer, :twitter }
    context 'with a valid twitter_website_url' do
      it_behaves_like 'it found a website craft'
      it 'sets the website_url to the twitter_website_url' do
        WebsiteHandler.populate_website_craft(hover_craft)
        expect(hover_craft.website_url).to eq hover_craft.twitter_website_url
      end
    end
    context 'with an invalid twitter_website_url' do
      let (:hover_craft)  { create :hover_craft, :streamer, :twitter, twitter_website_url: "" }
      it_behaves_like "it doesn't change anything"
    end
  end

  context 'given a yelp_craft but no twitter_craft' do
    let (:final_url)    { hover_craft.yelp_website_url }
    let (:hover_craft)  { build :hover_craft, :yelp }
    context 'with a valid yelp_website_url' do
      it_behaves_like 'it found a website craft'
      it 'sets the website_url to the yelp_website_url' do
        WebsiteHandler.populate_website_craft(hover_craft)
        expect(hover_craft.website_url).to eq hover_craft.yelp_website_url
      end
    end
    context 'with an invalid yelp_website_url' do
      let (:hover_craft)  { build :hover_craft, :yelp, yelp_website_url: "" }
      it_behaves_like "it doesn't change anything"
    end
  end
end