class Facebook
  SCOPE = 'user_actions:soundcloud'
  APP_ID = ENV["FACEBOOK_APP_ID"] or raise "env var FACEBOOK_APP_ID missing"
  APP_SECRET = ENV["FACEBOOK_SECRET"] or raise "env var FACEBOOK_SECRET missing"

  class OAuthException < StandardError
  end

  attr_reader :token

  def self.http
    Net::HTTP.new("graph.facebook.com", "443").tap do |http|
      http.use_ssl = true
    end
  end

  def self.parse_token(str)
    Rack::Utils.parse_query(str)['access_token']
  end

  def self.urlencode_hash(hash)
    hash.map do |key, value|
      "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
    end.join("&")
  end

  def self.get(path, params)
    http.get(path + '?' + urlencode_hash({ :client_id => APP_ID, :client_secret => APP_SECRET }.merge(params)))
  end

  def self.exchange_code(code, redirect_uri)
    res = get("/oauth/access_token", :code => code, :redirect_uri => redirect_uri)
    new(parse_token(res.body))
  end

  def self.exchange_token(token)
    res = get("/oauth/access_token", :grant_type => "fb_exchange_token", :fb_exchange_token => token)
    new(parse_token(res.body))
  end

  def initialize(token)
    @token = token
  end

  def get(path)
    res = self.class.http.get("#{path}?access_token=#{token}")

    result = JSON.parse(res.body)

    if result['error']
      raise OAuthException, result['error']['message']
    end

    result
  end

  def me
    @me ||= get('/me')
  end
end
