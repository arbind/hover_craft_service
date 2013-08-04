require 'spec_helper'
require 'sidekiq/testing'

describe WorkerResolveHoverCraftUrl do
  let (:subject)            { WorkerResolveHoverCraftUrl.new }
  let (:work_data)          { WorkerResolveHoverCraftUrl.work_data hover_craft.id, url_attribute }

  let (:url_attribute)      { :twitter_website_url}
  let!(:hover_craft)        { create :hover_craft, twitter_website_url: url }

  let (:url)                { 'http://t.co/123'}
  let (:final_url)          { 'http://the-real-deal.com'}
  before do
    Web.stub(:final_location_of_url).and_return(final_url)
  end

  it 'looks up the final url' do
    Web.should_receive(:final_location_of_url).with(url)
    subject.perform work_data
  end

  it 'updates the hover_craft with the final url' do
    expect {
      subject.perform work_data

    }.to change{hover_craft.reload[url_attribute]}.from(url).to(final_url)
  end

  it 'schedules WorkerFindWebCrafts for the hover_craft' do
    new_job_data = WorkerFindWebCrafts.work_data hover_craft.id
    WorkerFindWebCrafts.should_receive(:schedule).with new_job_data
    subject.perform work_data
  end
end