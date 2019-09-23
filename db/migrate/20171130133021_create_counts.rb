class CreateCounts < ActiveRecord::Migration[5.1]
  def change
    create_table :counts do |t|
      t.integer :count
      t.timestamps null: false
    end
  end
end
