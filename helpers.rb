
def urlencode_hash(hash)
  hash.map do |key, value|
    "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
  end.join("&")
end

helpers do
  def url(path)
    base = "#{request.scheme}://#{request.env['HTTP_HOST']}"
    base + path
  end

  def app_data
    { :appId => Facebook::APP_ID,
      :scope => Facebook::SCOPE,
      :userId => user ? user.uid : nil,
      :authUrl => auth_url }
  end

  def oembed(url)
    if embed = Soundcloud.oembed(url)
      embed['html']
    end
  end

  def auth_url
    "https://www.facebook.com/dialog/oauth?scope=#{Facebook::SCOPE}&client_id=#{Facebook::APP_ID}&redirect_uri=#{url('/auth')}"
  end

  def user
    if session[:user]
      @user ||= User.find_by_uid(session[:user])
    end
  end
end
