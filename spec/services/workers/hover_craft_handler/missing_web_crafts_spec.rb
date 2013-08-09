require 'spec_helper'
require 'sidekiq/testing'

describe :missing_web_crafts do
  let!(:completes)         { create_list :complete_hover_craft, 3 }
  let!(:missing_twitter)   { create_list :missing_twitter, 3 }
  let!(:missing_yelp)      { create_list :missing_yelp, 3 }
  let!(:missing_website)   { create_list :missing_website, 3 }
  let!(:missing_facebook)  { create_list :missing_facebook, 3 }
  let (:incompletes)       { missing_yelp + missing_website +  missing_twitter + missing_facebook }
  it 'schedules MissingWeCraftsNew for each hovercraft' do
    incompletes.each do |hover_craft|
      job_data = MissingWebCraftsNew.work_data hover_craft
      MissingWebCraftsNew.should_receive(:schedule).with(job_data)
    end
    HoverCraftHandler.missing_web_crafts
  end

  it 'queues StreamerFriendsNew jobs' do
    expect {
      HoverCraftHandler.missing_web_crafts
    }.to change(MissingWebCraftsNew.jobs, :size).by(incompletes.size)
  end
end