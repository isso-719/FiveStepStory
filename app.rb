require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'

enable :sessions

get '/' do
  erb :index
end

get '/signin' do

  erb :signin
end

post '/signin' do

  user = User.find_by(mail: params[:mail])
  if user && user.authenticate(params[:password])
    session[:user] = user.id

  redirect '/'
  else
    # erb :login_error
    redirect '/signin'

  end

end

get '/signup' do

  erb :signup
end

post '/signup' do
  @user = User.create(mail: params[:mail],password: params[:password],password_confirmation: params[:password_confirmation])
  if @user.persisted?
    session[:user] = @user.id
    redirect '/'
  else
    redirect '/signup'
  end
  erb :signup
end

get '/signout' do
  session[:user] = nil
end

get '/dic' do

  erb :dic
end

post '/dic/new' do

  User.find(session[:user]).contents.create(
    c_when: params[:c_when],c_where: params[:c_where],c_who: params[:c_who],c_what: params[:c_what],c_how: params[:c_how]
  )

  redirect '/'

end

get '/play/r' do

  erb :r_play
end