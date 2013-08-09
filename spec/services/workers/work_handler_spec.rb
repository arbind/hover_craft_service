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

  describe :streamer_friends do
    let (:worker)         { StreamerFriends }
    let (:handler_class)  { TwitterHandler }
    let (:args)           { [] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :streamer_friends_new do
    let (:worker)         { StreamerFriendsNew }
    let (:handler_class)  { TwitterHandler }
    let (:args)           { [streamer, page] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :streamer_friends_create do
    let (:worker)         { StreamerFriendsCreate }
    let (:handler_class)  { TwitterHandler }

    let (:args)           { [streamer, ids] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :twitter_craft_new do
    let (:worker)         { TwitterCraftNew }
    let (:handler_class)  { TwitterHandler }
    let (:args)           { [hover_craft] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :twitter_craft_create do
    let (:worker)         { TwitterCraftCreate }
    let (:handler_class)  { TwitterHandler }
    let (:args)           { [hover_craft] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :resolve_url do
    let (:worker)         { ResolveUrl }
    let (:handler_class)  { HoverCraftHandler }
    let (:args)           { [hover_craft, url_attribute] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :website_links do
    let (:worker)         { WebsiteLinks }
    let (:handler_class)  { WebsiteHandler }
    let (:args)           { [hover_craft] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :missing_web_crafts do
    let (:worker)         { MissingWebCrafts }
    let (:handler_class)  { HoverCraftHandler }
    let (:args)           { nil }
    let (:data)           { worker.work_data }
    it_behaves_like 'a work handler'
  end

  describe :missing_web_crafts_new do
    let (:worker)         { MissingWebCraftsNew }
    let (:handler_class)  { HoverCraftHandler }
    let (:args)           { [hover_craft] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :yelp_craft_new do
    let (:worker)         { YelpCraftNew }
    let (:handler_class)  { YelpHandler }
    let (:args)           { [hover_craft] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

  describe :yelp_craft_create do
    let (:worker)         { YelpCraftCreate }
    let (:handler_class)  { YelpHandler }
    let (:args)           { [hover_craft] }
    let (:data)           { worker.work_data *args }
    it_behaves_like 'a work handler'
  end

end