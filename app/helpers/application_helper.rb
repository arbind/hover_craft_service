module ApplicationHelper

  def url_domain(href)
    return nil unless href
    href.url_domain
  end
  
  def put_link_to (endpoint_path, options={})
    form_link_to endpoint_path, :post, options
  end

  def post_link_to (endpoint_path, options={})
    form_link_to endpoint_path, :post, options
  end

  def patch_link_to (endpoint_path, options={})
    form_link_to endpoint_path, :post, options
  end

  def delete_link_to (endpoint_path, options={})
    form_link_to endpoint_path, :delete, {confirm: true}.merge(options)
  end

  def form_link_to (endpoint_path, method, options={})
    text = options.fetch(:text, ' ')
    css_class = options.fetch(:class, nil)
    title = options.fetch(:title, nil)
    confirm = "#{title}?" if options[:confirm]
    settings = {
      method: method,
      class: css_class,
      title: title,
      confirm: confirm
    }
    link_to text, endpoint_path, settings
  end
end
