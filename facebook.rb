class Facebook
  SCOPE = 'user_actions:soundcloud'
  APP_ID = ENV["FACEBOOK_APP_ID"] or raise "please set the environment variable FACEBOOK_APP_ID"
  APP_SECRET = ENV["FACEBOOK_SECRET"] or raise "please set the environment variable FACEBOOK_SECRET"

  # This will be thrown for any message returning with an error
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

  # Request new access token
  def self.access_token(params)
    http.get('/oauth/access_token?' + urlencode_hash({ :client_id => APP_ID, :client_secret => APP_SECRET }.merge(params)))
  end

  # Request access token for given authorization code
  def self.exchange_code(code, redirect_uri)
    res = access_token(:code => code, :redirect_uri => redirect_uri)
    new(parse_token(res.body))
  end

  # Refresh short-lived token with a long-lived one
  def self.exchange_token(token)
    res = access_token(:grant_type => "fb_exchange_token", :fb_exchange_token => token)
    new(parse_token(res.body))
  end

  def initialize(token)
    @token = token
  end

  # Access user related information using the user access token
  # Raise OAuthException if Facebook returns error
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
