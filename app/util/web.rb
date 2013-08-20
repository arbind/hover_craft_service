class Web
  def self.site(url_string) Web.new(url_string) end

  def initialize(url_string)
    @site = Nokogiri::HTML(open url_string, 'User-Agent' => 'ruby')
  end

  def select_all(css) @site.css(css) end

  def select_first(css) select_all(css).first end

  def title
    select_first('title').content
  end

  def links(match=nil)
    if match.nil?
      elements = select_all("a[href]")
    else
      elements = select_all("a[href*=#{match}]")
    end
    elements.map{|e| e[:href]}
  end

  def self.provider_href?(url)
    return false if url.nil?
    href = url.to_href
    return false if href.nil?
    href.match /^http(s)?\:\/\/(www.)?(yelp)?(facebook)?(twitter)?\.com/i
  end
  def self.final_location_of_url(url)
    return "" if url.nil? or url.strip.empty?
    final_location = nil
    begin
      open(url.strip,'User-Agent' => 'ruby') {|resp| final_location=resp.base_uri}
    rescue RuntimeError => e
      if e.message.match /redirection forbidden/
        final_location = e.message.split('->').last.strip
        # redirection forbidden: http://abc.com/tacs -> https://abc.com/taco
      end
    rescue OpenURI::HTTPError => e
      # 403 forbidden, 404 not found, etc
    rescue SocketError => e
      # No DNS
    end
    final_location.to_s
  end
end