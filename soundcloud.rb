class Soundcloud
  APP_ID = 'YOUR_CLIENT_ID'

  def self.http(domain = "api.soundcloud.com")
    Net::HTTP.new(domain, 80)
  end

  def self.get(path, params={})
    JSON.parse(http.get(path + '.json?' + urlencode_hash({ :client_id => APP_ID }.merge(params))).body)
  end

  # Returns an embeddable player
  def self.oembed(url)
    JSON.parse(http('soundcloud.com').get('/oembed?' + urlencode_hash(:format => 'json', :url => url)).body)
  rescue JSON::ParserError
  end
end
