require 'spec_helper'

describe String do
  let (:naked)          { 'gocomics.com/calvinandhobbes' }
  let (:http_url)       { "http://#{naked}" }
  let (:http_url2)      { "http://#{naked}/" }
  let (:https_url)      { "https://#{naked}" }
  let (:https_www_url)   { "https://www.#{naked}" }
  describe '#to_href' do
    it 'adds http to a naked url' do
      expect(naked.to_href).to eq http_url
    end
    it 'returns itself for an http url' do
      expect(http_url.to_href).to eq http_url
    end
    it 'returns preserves trailing slash ' do
      expect(http_url2.to_href).to eq http_url2
    end
    it 'returns itself for an https url' do
      expect(https_url.to_href).to eq https_url
    end
    it 'keeps the www.' do
      expect(https_www_url.to_href).to eq https_www_url
    end

  end
end