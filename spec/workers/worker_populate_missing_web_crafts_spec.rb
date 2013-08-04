require 'spec_helper'
require 'sidekiq/testing'

describe WorkerPopulateMissingWebCrafts do
  let (:subject)          { WorkerPopulateMissingWebCrafts.new }
  let!(:missing_twitter)  { create_list :missing_twitter, 3 }
  let!(:missing_yelp)     { create_list :missing_yelp, 3 }
  let!(:missing_website)  { create_list :missing_website, 3 }
  let!(:missing_facebook) { create_list :missing_facebook, 3 }
  let!(:complete_hover_crafts)   { create_list :complete_hover_crafts, 3 }
  let!(:incomplete_hover_crafts) { missing_twiter + missing_yelp + missing_website + missing_facebook }
  it 'schedules WorkerCreateHoverCraftsForNewStreamerFriends for incomplete_hover_crafts'
  # it 'schedules WorkerCreateHoverCraftsForNewStreamerFriends for incomplete_hover_crafts' do
  #   incomplete_hover_crafts.each do |hc|
  #     job_data = WorkerFindWebCrafts.work_data hc.id
  #     WorkerFindWebCrafts.should_receive(:schedule).with(job_data)
  #   end
  #   subject.perform
  # end
end