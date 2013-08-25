require 'spec_helper'
require 'sidekiq/testing'

describe :yelp_scan_for_link do
  let (:hover_craft)      { create :hover_craft, yelp_href: yelp_href }
  let (:yelp_href)        { 'http://www.yelp.com/biz/paiche-marina-del-rey' }

  let (:biz_website)      { 'paichela.com' }
  let (:yelp_website_url) { "http://#{biz_website}" }

  let!(:mock_web)         { Web.stub_chain(:site, :select_first).and_return(mock_element) }
  let (:mock_element)     { double :nokogiri_element, content: biz_website }

  it 'updates yelp_website_url' do
    expect {
      YelpHandler.yelp_scan_for_link hover_craft
    }.to change(hover_craft.reload, :yelp_website_url).to(yelp_website_url)
  end

  it 'resolves yelp_website_url'

  it 'schedules a PopulateHoverCraft' do
    new_job_data = PopulateHoverCraft.work_data hover_craft
    PopulateHoverCraft.should_receive(:schedule).with new_job_data
    YelpHandler.yelp_scan_for_link hover_craft
  end
end
