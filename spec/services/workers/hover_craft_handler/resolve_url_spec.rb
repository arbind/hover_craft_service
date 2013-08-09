require 'spec_helper'
require 'sidekiq/testing'

describe :resolve_url do
  let (:url)           { 'http://t.co/123'}
  let (:final_url)     { nil }
  let (:url_attribute) { :twitter_website_url}
  let!(:hover_craft)   { create :hover_craft, twitter_website_url: url }
  let (:work_data)     { ResolveUrl.work_data hover_craft, url_attribute }
  before { Web.stub(:final_location_of_url).and_return(final_url) }

  shared_examples_for 'a final_url handler' do
    it 'looks up the final url' do
      Web.should_receive(:final_location_of_url).with(url)
      HoverCraftHandler.resolve_url work_data
    end

    it 'updates the hover_craft with the final url' do
      if url.eql? final_url or final_url.empty?
        expect {
          HoverCraftHandler.resolve_url work_data
        }.not_to change{hover_craft.reload[url_attribute]}
      else
        expect {
          HoverCraftHandler.resolve_url work_data
        }.to change{hover_craft.reload[url_attribute]}.from(url).to(final_url)
      end
    end

  end

  context 'given a bad url' do
    let (:final_url) { '' }
    it_behaves_like 'a final_url handler'
  end

  context 'given an already finalized url' do
    let (:final_url) { url }
    it_behaves_like 'a final_url handler'
  end

  context 'given a url that redirects' do
    let (:final_url) { 'http://the-real-deal.com'}
    it_behaves_like 'a final_url handler'

    it 'schedules WorkerFindWebCrafts for the hover_craft' do
      new_job_data = MissingWebCrafts.work_data hover_craft
      MissingWebCrafts.should_receive(:schedule).with new_job_data
      HoverCraftHandler.resolve_url work_data
    end
  end
end