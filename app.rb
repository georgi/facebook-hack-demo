require "sinatra"
require "./facebook"
require "./models"

enable :sessions
set :raise_errors, false
set :show_exceptions, false

before do
  # HTTPS redirect
  if settings.environment == :production && request.scheme != 'https'
    redirect "https://#{request.env['HTTP_HOST']}"
  end
end

helpers do
  def url(path)
    base = "#{request.scheme}://#{request.env['HTTP_HOST']}"
    base + path
  end

  def config
    { :appId => Facebook::APP_ID,
      :scope => Facebook::SCOPE,
      :authUrl => auth_url }
  end

  def auth_url
    "https://www.facebook.com/dialog/oauth?scope=#{Facebook::SCOPE}&client_id=#{Facebook::APP_ID}&redirect_uri=#{url('/signup')}"
  end

  def user
    if session[:user]
      @user ||= User.find_by_id(session[:user])
    end
  end
end

get "/" do
  erb :index
end

post "/" do
  redirect "/"
end

get "/signup" do
  client = Facebook.exchange_code(params[:code], url('/signup'))
  user = User.from_facebook(client)
  session[:user] = user.id
  redirect '/'
end

post "/login" do
  client = Facebook.exchange_token(params[:token])
  user = User.from_facebook(client)
  session[:user] = user.id
  redirect '/'
end
