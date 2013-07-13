class Web
  def self.site(url_string) Web.new(url_string) end

  def initialize(url_string)
    @site = Nokogiri::HTML(open url_string, 'User-Agent' => 'ruby')
  end

  def select_all(css) @site.css(css) end

  def select_first(css) select_all(css).first end

end