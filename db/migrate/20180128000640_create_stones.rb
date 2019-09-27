class CreateStones < ActiveRecord::Migration[5.1]
  def change
    create_table :stones do |t|
      t.string :color
      t.string :when
      t.string :where
      t.string :who
      t.string :what
      t.string :how
      t.integer :x
      t.integer :y
      t.integer :game_id
      t.timestamps null: false
    end
  end
end
