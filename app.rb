require "sinatra"
require 'json'
require 'net/http'
require 'cgi'

require "./soundcloud"
require "./facebook"
require "./user"
require "./helpers"

enable :sessions

# Redirect to HTTPS if necessary
before do
  if settings.environment == :production && request.scheme != 'https'
    redirect "https://#{request.env['HTTP_HOST']}"
  end
end

# Shows a list of recent plays on SoundCloud
get "/" do
  begin
    if user
      # Logged in users have a Facebook connection
      artists = user.facebook.get('/me/music.listens')['data'].map do |action|
        action['data']['musician']['title']
      end

      raise artists.to_json
    end

    # rendering html template
    erb :index

  # Access Token is expired, so we reauth the user on Facebook
  rescue Facebook::OAuthException
    redirect auth_url
  end
end

# Redirect posts from Facebook Canvas Page
post "/" do
  redirect "/"
end

# Callback endpoint for server side flow
# Takes a OAuth code parameter and creates a user if necessary
get "/auth" do
  client = Facebook.exchange_code(params[:code], url('/auth'))
  user = User.from_facebook(client)
  session[:user] = user.uid
  redirect '/'
end

# Login endpoint for client side flow
# Takes a token paremeter and creates a user if necessary
post "/auth" do
  client = Facebook.exchange_token(params[:token])
  user = User.from_facebook(client)
  session[:user] = user.uid
  redirect '/'
end
