ENV["APPLICATION_URL"] ||= "http://0.0.0.0:3000"

module LOCAL    # dev config for running on localhost
  module TWITTER
    KEY     = "6QOEygXZwne9IXahN0STtQ"
    SECRET  = "EmotufoC4hdWpURUHWy5xhGSH25ZDtmPCTLsK72A"
  end
end

module SECRET
  module TWITTER
    KEY     = ENV["TWITTER_KEY"]    || LOCAL::TWITTER::KEY
    SECRET  = ENV["TWITTER_SECRET"] || LOCAL::TWITTER::SECRET
  end
end
