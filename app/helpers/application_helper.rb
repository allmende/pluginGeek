module ApplicationHelper
  def dns_prefetch_tag(url)
    "<link rel='dns-prefetch' href='#{ url }'>".html_safe
  end

  def icon_tag(type, text=nil)
    content_tag :i, text, class: "fa fa-#{ type }"
  end

  def markdown(text)
    options = {
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true
    }
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, options).render(text).html_safe
  end

  # Don't render sensitive content (like user info)
  # when the response headers indicate that the response
  # is to be cached in public caches (such as e.g. Rack::Cache)
  def publicly_cached?
    !!(response.cache_control[:public])
  end

  def nbsp
    ' '
  end

  def navigation
    Navigation.new(request.path)
  end

  def support_email
    'hi@plugingeek.com'
  end

  def new_action?
    params[:action] == 'new'
  end

  def edit_action?
    params[:action] == 'edit'
  end
end
