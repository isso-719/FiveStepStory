class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.string :turn
      t.string :status
      t.integer :user_id
      t.integer :pass_count
      t.timestamps null: false
    end
  end
end
