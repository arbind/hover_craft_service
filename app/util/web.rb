class Web
  def self.site(url_string) Web.new(url_string) end

  def initialize(url_string)
    @site = Nokogiri::HTML(open url_string, 'User-Agent' => 'ruby')
  end

  def select_all(css) @site.css(css) end

  def select_first(css) select_all(css).first end

  def self.final_location_of_url(url)
    return "" if url.nil? or url.strip.empty?
    final_location = nil
    open(url.strip) {|resp| final_location=resp.base_uri}
    final_location.to_s
  rescue OpenURI::HTTPError => e
    if e.message.match /404/ # 404 Not Found
      final_location = ""
    else
      Rails.logger.error ":: Error finding final_location_of_url #{url}: #{e.message}"
    end
  rescue SocketError => e
    # No DNS
    final_location = ""
  rescue RuntimeError => e
    if e.message.match /redirection forbidden/
      # redirection forbidden: http://abc.com/tacs -> https://abc.com/taco
      final_location = e.message.split('->').last.strip
    else
      Rails.logger.error ":: Error finding final_location_of_url #{url}: #{e.message}"
    end
  rescue Exception => e
    Rails.logger.error ":: Error finding final_location_of_url #{url}: #{e.message}"
  end

end