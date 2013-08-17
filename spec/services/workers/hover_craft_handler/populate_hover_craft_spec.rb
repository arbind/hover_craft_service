require 'spec_helper'
require 'sidekiq/testing'

describe :populate_hover_craft do

  shared_examples_for 'it populates web_craft for:' do |web_craft_type|
    let (:worker) { :"populate_#{web_craft_type.to_s}_craft"}
    let (:worker_class) { "#{worker.to_s}".camelize.constantize }
    it "schedules a populate for that web_craft" do
      job_data = worker_class.work_data hover_craft
      worker_class.should_receive(:schedule).with(job_data)
      HoverCraftHandler.populate_hover_craft hover_craft
    end

    it "queues a job for that web_craft" do
      expect {
        HoverCraftHandler.populate_hover_craft hover_craft
      }.to change(worker_class.jobs, :size).by(1)
    end
  end

  shared_examples_for 'it does not populate web_craft for:' do |web_craft_type|
    let (:worker) { :"populate_#{web_craft_type.to_s}_craft"}
    let (:worker_class) { "#{worker.to_s}".camelize.constantize }
    it "does not schedules a populate for that web_craft" do
      job_data = worker_class.work_data hover_craft
      worker_class.should_not_receive(:schedule).with(job_data)
      HoverCraftHandler.populate_hover_craft hover_craft
    end

    it "queues a job for that web_craft" do
      expect {
        HoverCraftHandler.populate_hover_craft hover_craft
      }.to change(worker_class.jobs, :size).by(0)
    end

  end

  context 'web_craft is missing' do
    let!(:hover_craft) { create :hover_craft, :twitter }
    context 'yelp is missing' do
      it_behaves_like 'it populates web_craft for:', :yelp
    end
    context'facebook is missing' do
      it_behaves_like 'it populates web_craft for:', :facebook
    end
    context 'website is missing' do
      it_behaves_like 'it populates web_craft for:', :website
    end
    context 'twitter is missing' do
      let!(:hover_craft) { create :hover_craft, :yelp}
      it_behaves_like 'it populates web_craft for:', :twitter
    end
  end


  context 'web_craft is present' do
    let!(:hover_craft) { create :complete_hover_craft}
    context 'yelp is present' do
      it_behaves_like 'it does not populate web_craft for:', :yelp
    end
    context'facebook is present' do
      it_behaves_like 'it does not populate web_craft for:', :facebook
    end
    context 'website is present' do
      it_behaves_like 'it does not populate web_craft for:', :website
    end
    context 'twitter is present' do
      it_behaves_like 'it does not populate web_craft for:', :twitter
    end
  end
end
