ActiveRecord::Base.establish_connection("sqlite3:db/development.db")

class User < ActiveRecord::Base
  has_secure_password
  has_many :contents
end

class Content < ActiveRecord::Base
  belongs_to :user
end