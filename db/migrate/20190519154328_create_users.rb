class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :mail
      t.string :password_digest
      t.timestamps null: false
    end
  end
end
