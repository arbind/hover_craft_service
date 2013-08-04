require 'spec_helper'
require 'sidekiq/testing'

describe WorkerFindWebCrafts do
  let (:subject)   { WorkerFindWebCrafts.new }
  it 'looks for a YelpCraft'
  it 'looks for a FacebookCraft'
  it 'looks for a WebsiteCraft'
  context 'When a new WebCraft is found' do
    context 'When a new WebsiteCraft is found' do
      it 'schedules a WorkerScanWebsiteForLinks'
    end
    context 'if there are still some missing webcrafts' do
      it 'reschedules itself' # to find more webcrafts from the new info
    end
    context 'and all webcrafts are present' do
      it 'does not reschedule itself' # avoid infinit recursion
    end
  end
end