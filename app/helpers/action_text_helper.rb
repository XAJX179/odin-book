module ActionTextHelper
  def yt_link?(href)
  return false if href.blank?

  host = URI.parse(href).host

  [
    "www.youtube.com",
    "m.youtube.com",
    "youtu.be",
    "www.youtube-nocookie.com"
  ].include?(host)
  rescue URI::InvalidURIError
    false
  end

  def yt_embed_link(href)
    uri = URI.parse(href)

    if uri.host.include?("youtu.be")
      id = uri.path.delete_prefix("/")
    else
      params = CGI.parse(uri.query.to_s)
      id = params["v"]&.first
    end
    "https://www.youtube-nocookie.com/embed/#{id}"
  end
end
