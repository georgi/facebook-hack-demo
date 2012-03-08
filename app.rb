require "sinatra"
require 'json'
require 'net/http'
require 'cgi'

require "./soundcloud"
require "./facebook"
require "./user"
require "./helpers"

enable :sessions

before do
  if settings.environment == :production && request.scheme != 'https'
    redirect "https://#{request.env['HTTP_HOST']}"
  end
end

get "/" do
  begin
    if user
      @actions = user.facebook.get('/me/soundcloud:listen')['data']
    end

    erb :index

  rescue Facebook::OAuthException
    redirect auth_url
  end
end

post "/" do
  redirect "/"
end

get "/auth" do
  client = Facebook.exchange_code(params[:code], url('/auth'))
  user = User.from_facebook(client)
  session[:user] = user.uid
  redirect '/'
end

post "/auth" do
  client = Facebook.exchange_token(params[:token])
  user = User.from_facebook(client)
  session[:user] = user.uid
  redirect '/'
end
