require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
require 'sinatra/reloader'
require 'sinatra-websocket'
require 'json'
require 'sinatra/activerecord'

set :server, 'thin'
set :sockets, []

enable :sessions

before do
  Count.create(count: 0) if Count.all.size == 0
end

get '/' do
  @count = Count.first.count
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

  redirect '/'
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

  c_contents = Content.where(user_id: session[:user])
  content_id = []
  c_contents.each do |content|
    content_id.push(content.id)
  end

  @c_random = Content.find_by(id: content_id.sample)
  @r_when = @c_random.c_when

  @c_random = c_contents.find_by(id: content_id.sample)
  @r_where = @c_random.c_where

  @c_random = c_contents.find_by(id: content_id.sample)
  @r_who = @c_random.c_who

  @c_random = c_contents.find_by(id: content_id.sample)
  @r_what = @c_random.c_what

  @c_random = c_contents.find_by(id: content_id.sample)
  @r_how = @c_random.c_how


  erb :r_play
end

get '/websocket/count' do
  if request.websocket? then
    request.websocket do |ws|
      ws.onopen do # 接続を開始した時
        settings.sockets << ws # socketsリストに追加
        c = Count.first # count の数を増やす
        c.count += 1
        c.save
        settings.sockets.each do |s| # 全体へメッセージを転送
          c = Count.first
          s.send({type: 'count', count: c.count}.to_json.to_s)
        end
      end
      ws.onmessage do |msg| # メッセージを受け取った時
        puts 'メッセージを受け取ったよ！'
        data = JSON.parse(msg)
        case data['type']
        when 'open', 'close' # 送られたデータが open or close データだったら
          settings.sockets.each do |s| # 全体へメッセージを転送
            c = Count.first
            s.send({type: 'count', count: c.count}.to_json.to_s)
          end
      end
      ws.onclose do # メッセージを終了する時
        c = Count.first # count の数を減らす
        c.count -= 1
        c.save
        settings.sockets.each do |s| # 全体へメッセージを転送
          c = Count.first
          s.send({type: 'count', count: c.count}.to_json.to_s)
        end
        settings.sockets.delete(ws) # socketsリストから削除
        end
      end
    end
  end
end