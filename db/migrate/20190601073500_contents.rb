class Contents < ActiveRecord::Migration[5.2]
  def change
      create_table :contents do |t|
      t.references :user
      t.string :c_when
      t.string :c_where
      t.string :c_who
      t.string :c_what
      t.string :c_how
      t.timestamps null: false
      end
  end
end
