require 'json'
require 'net/http'
require 'uri'

class Facebook
  SCOPE = 'publish_actions'
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

  def self.exchange_code(code, redirect_uri)
    res = http.get("/oauth/access_token?client_id=#{APP_ID}&client_secret=#{APP_SECRET}&code=#{code}&redirect_uri=#{URI.encode redirect_uri}")
    new(parse_token(res.body))
  end

  def self.exchange_token(token)
    res = http.get("/oauth/access_token?client_id=#{APP_ID}&client_secret=#{APP_SECRET}&grant_type=fb_exchange_token&fb_exchange_token=#{token}")
    new(parse_token(res.body))
  end

  def initialize(token)
    @token = token
  end

  def get(path)
    res = self.class.http.get("#{path}?access_token=#{token}")

    result = JSON.parse(res.body)

    if result['error']
      raise OAuthException, result['message']
    end

    result
  end

  def me
    @me ||= get('/me')
  end

  def name
    me['name']
  end

  def uid
    me['id']
  end
end
