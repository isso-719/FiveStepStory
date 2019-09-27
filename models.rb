require 'bundler/setup'
Bundler.require

if development?
  ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class Count < ActiveRecord::Base
end

class Game < ActiveRecord::Base
  has_many :stones
  has_many :users, through: :game_users
  has_many :game_users
  belongs_to :user
  accepts_nested_attributes_for :game_users
  def init
    Stone.create({game_id: self.id, x: 3, y: 3, color: 'black'})
    Stone.create({game_id: self.id, x: 2, y: 2, color: 'black'})
    Stone.create({game_id: self.id, x: 3, y: 2, color: 'white'})
    Stone.create({game_id: self.id, x: 2, y: 3, color: 'white'})
  end

  def countColor
    black  = self.stones.where({color: 'black'}).count
    white = self.stones.where({color: 'white'}).count
    {:black => black, :white => white}
  end

  def joinUser(user_id)
    self.game_users.first.user_id == user_id ||
    self.game_users.second.nil? ? true : self.game_users.second.user_id == user_id
  end

  def winner
    white = self.stones.where({color: 'white'}).count
    black = self.stones.where({color: 'black'}).count
    if white == black
      -1
    elsif white > black
      self.game_users.first.user_id
    else
      self.game_users.second.user_id
    end
  end
end

class Stone < ActiveRecord::Base
  belongs_to :game
end

class User < ActiveRecord::Base
  has_secure_password
  validates :name,
    presence: true
  validates :password,
    length: {in: 5..10}
  has_many :games
  has_many :games, through: :game_users
  has_many :game_users
  has_many :contents
end

class Content < ActiveRecord::Base
  belongs_to :user
end

class GameUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
end