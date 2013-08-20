require 'spec_helper'

describe WorkHandler do
  let (:streamer)       { create :tweet_streamer}
  let (:hover_craft)    { create :hover_craft}
  let (:ids)            { [1,2,3,4] }
  let (:page)           { 0 }
  let (:url_attribute)  { :twitter_url_website }

  shared_examples_for 'a work handler' do
    it 'delegates to a work handler' do
      handler = worker.name.underscore.to_sym
      if args.present?
        expect(handler_class).to receive(handler).with(*args)
        WorkHandler.send handler, data
      else
        expect(handler_class).to receive(handler)
        WorkHandler.send handler, {}
      end
    end
  end

  describe :populate_hover_crafts do
    let (:worker)         { PopulateHoverCrafts }
    let (:handler_class)  { HoverCraftHandler }
    let (:args)           { nil }
    let (:data)           { worker.work_data }
    it_behaves_like 'a work handler'
  end

  describe :populate_hover_craft do
    let (:worker)         { PopulateHoverCraft }
    let (:handler_class)  { HoverCraftHandler }
    let (:args)           { [hover_craft] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :populate_twitter_craft do
    let (:worker)         { PopulateTwitterCraft }
    let (:handler_class)  { TwitterHandler }
    let (:args)           { [hover_craft] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :populate_yelp_craft do
    let (:worker)         { PopulateYelpCraft }
    let (:handler_class)  { YelpHandler }
    let (:args)           { [hover_craft] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :populate_facebook_craft do
    let (:worker)         { PopulateFacebookCraft }
    let (:handler_class)  { FacebookHandler }
    let (:args)           { [hover_craft] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :populate_website_craft do
    let (:worker)         { PopulateWebsiteCraft }
    let (:handler_class)  { WebsiteHandler }
    let (:args)           { [hover_craft] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :populate_from_streamers do
    let (:worker)         { PopulateFromStreamers }
    let (:handler_class)  { TwitterHandler }
    let (:args)           { [] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :populate_from_streamer do
    let (:worker)         { PopulateFromStreamer }
    let (:handler_class)  { TwitterHandler }
    let (:args)           { [streamer, page] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :populate_from_streamer_friends do
    let (:worker)         { PopulateFromStreamerFriends }
    let (:handler_class)  { TwitterHandler }

    let (:args)           { [streamer, ids] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :hover_craft_resolve_url do
    let (:worker)         { HoverCraftResolveUrl }
    let (:handler_class)  { HoverCraftHandler }
    let (:args)           { [hover_craft, url_attribute] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :yelp_scan_for_link do
    let (:worker)         { YelpScanForLink }
    let (:handler_class)  { YelpHandler }
    let (:args)           { [hover_craft] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

end