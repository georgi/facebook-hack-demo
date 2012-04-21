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
      artists = []

      data = user.facebook.get("/#{user.uid}/music.listens")['data']
      songs = data.map {|action| action['data']['song']['id'] }.compact

      threads = songs.map do |song|
        Thread.new do
          artists << user.facebook.get("/#{song}")['data']['musician'][0]['name']
        end
      end

      threads.each {|t| t.join }

      artists.compact!
      artists.uniq!

      @users = []

      threads = artists.map do |artist|
        Thread.new do
          if user = Soundcloud.get('/e1/search/people', :q => artist)[0]
            if user['track_count'] > 0
              @users << user
            end
          end
        end
      end

      threads.each {|t| t.join }

      @users.compact!
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
