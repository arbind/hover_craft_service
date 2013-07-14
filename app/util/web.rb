class Web
  def self.site(url_string) Web.new(url_string) end

  def self.final_location_of_url(url)
    return "" if url.nil? or url.empty?
    final_location = nil
    open(url) {|resp| final_location=resp.base_uri}
    final_location.to_s
  end

  def initialize(url_string)
    @site = Nokogiri::HTML(open url_string, 'User-Agent' => 'ruby')
  end

  def select_all(css) @site.css(css) end

  def select_first(css) select_all(css).first end

end