require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra-websocket'
require 'json'
require './models'
require './src/login'

enable :sessions

set :server, 'thin'
set :sockets, {}

before do
  User.create({name: 'なし',
    password: 'foovar',
    password_confirmation: 'foovar'}) if User.all.size == 0
end

get '/' do
  @title = "Home"
  @rooms = Game.all.reverse
  erb :index
end

# 一人用
get '/dic' do

  erb :dic
end

post '/dic/new' do

  User.find(session[:user]).contents.create(
    c_when: params[:c_when],c_where: params[:c_where],c_who: params[:c_who],c_what: params[:c_what],c_how: params[:c_how]
  )

  redirect '/#page/5'

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

get '/joined/:user_id' do
  @title = "User Prifile"
  @user = User.find(params[:user_id])
  @rooms = GameUser.where({user_id: params[:user_id]}).map{|gu| gu.game }
  erb :index
end

post '/create_room' do
  game = Game.create({:turn => 'white', :status => 'waiting'})
  game.init
  GameUser.create({user_id: session[:user], game_id: game.id})
  redirect "/room/#{game.id}"
end

get '/profile/:user' do
  @user = User.where({name: params[:user]}).first
  @title = "profile: #{@user.name}"
  @games = GameUser.where({user_id: @user.id})
  @wins = @games.select{|game|
    winner = game.game.turn == 'white' ? 0 : 1
    game.game.game_users[winner].user.name == @user.name
  }
  erb :profile
end

# 二人用
get '/play/m' do
  @title = "Home"
  @rooms = Game.all.reverse
  erb :multiplay
end

get '/room/:id' do
  @board_size = 6
  @title = "Room No.#{params[:id]}"
  @room = Game.find(params[:id])
  @turn_name = @room.turn
  @stones = @room.stones
  @users = GameUser.where({:game => params[:id]})
  user_idx = @room.turn == 'white' ? 0 : 1
  @user_id = GameUser.where({:game => params[:id]})[user_idx].user.id
  erb :room
end

get '/websocket/:id' do |path|
  if request.websocket? then
    request.websocket do |ws|
      ws.onopen do # 接続を開始した時
        settings.sockets[path] ||= []
        settings.sockets[path] << ws # socketsリストに追加
      end
      ws.onmessage do |msg| # メッセージを受け取った時
        puts 'メッセージを受け取ったよ！'
        data = JSON.parse(msg)
        puts data
        case data['type']
        when 'board' # 送られたデータが board データだったら
          game = Game.find(path)
          pos = data['pos']
          stone = Stone.find_or_initialize_by({game_id: path, x: pos[1], y: pos[0]})
          stone.update({game_id: path, x: pos[1], y: pos[0], color: game.turn})
          settings.sockets[path].each do |s| # メッセージを転送
            s.send({type: 'board', turn: data['turn'], pos: data['pos']}.to_json.to_s)
          end
        when 'turn' # 送られたデータが turn データだったら
          game = Game.find(path)
          game.turn = game.turn == 'black' ? 'white' : 'black'
          game.pass_count = 0
          user = GameUser.where({:game => game.id})[(game.stones.count + 1) % 2].user

          settings.sockets[path].each do |s| # メッセージを転送
            s.send({type: 'turn', turn: game.turn, user_id: user.id}.to_json.to_s)
          end
          game.save
        when 'join'
          user = User.find(data['user_id'])
          GameUser.create({
            user_id: data['user_id'],
            game_id: data['room_id']
            })
          Game.find(path).update({status: 'doing'})

          settings.sockets[path].each do |s| # メッセージを転送
            puts s
            s.send({type: 'join', name: user.name, id: user.id}.to_json.to_s)
          end
        when 'pass'
          game = Game.find(path)
          game.pass_count += 1
          if(game.pass_count >= 2)
            game.user_id = game.winner
            puts 'display'
            puts game.user_id
            puts game.user
            game.status = 'finished'
            settings.sockets[path].each do |s| # メッセージを転送
              count_color = game.countColor
              s.send({type: 'finished', winner: game.user.name }.to_json.to_s)
            end
          else
            game.turn = game.turn == 'black' ? 'white' : 'black'
            user = GameUser.where({:game => game.id})[(game.stones.count + 1) % 2].user
            settings.sockets[path].each do |s| # メッセージを転送
              s.send({type: 'turn', turn: game.turn, user_id: user.id}.to_json.to_s)
            end
          end
          game.save
        end
      end
      ws.onclose do # メッセージを終了する時
        game = Game.find(path)
        white = game.game_users.first.user
        black = game.game_users.second ? game.game_users.second.user : nil
        if session[:user].nil? or game['status'] == 'finished'
          puts 'else'
          settings.sockets[path].delete(ws) # socketsリストから削除
        elsif black.nil? # 黒が来ずログアウトした
          puts 'waiting'
          game.update({status: 'finished', user_id: 1})
          user = User.first
          GameUser.create({user_id: user.id, game_id: game.id })
          settings.sockets[path].each do |s| # メッセージを転送
            s.send({type: 'finished', winner: user.name }.to_json.to_s)
          end
        elsif white.id == session[:user]
          puts 'white'
          game.update({status: 'finished', user_id: black.id})
          settings.sockets[path].delete(ws) # socketsリストから削除
          settings.sockets[path].each do |s| # メッセージを転送
            s.send({type: 'finished', winner: black.name }.to_json.to_s)
          end
        elsif black.id == session[:user]
          puts 'black'
          game.update({status: 'finished', user_id: white.id})
          settings.sockets[path].delete(ws) # socketsリストから削除
          settings.sockets[path].each do |s| # メッセージを転送
            s.send({type: 'finished', winner: white.name }.to_json.to_s)
          end
        end
      end
    end
  end
end