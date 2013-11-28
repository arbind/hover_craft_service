class String
  def to_href
    uri = URI.parse(self)
    uri = URI.parse("http://#{self}") if uri.host.nil?
    uri.to_s
  rescue
    nil
  end

  def url_path
    self.gsub(/^http(s)?\:\/\/(www.)?.*\.com/i, '')
  end

  def url_domain
    self.gsub(/^http(s)?\:\/\/(www.)?/i, '')
  end

end