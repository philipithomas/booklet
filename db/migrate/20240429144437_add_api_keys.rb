class AddAPIKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :api_keys do |t|
      t.string :key_hash, null: false
      t.references :community, null: false, foreign_key: true
      t.string :name, null: false
      t.datetime :last_used_at, null: true

      t.timestamps
    end
    add_index :api_keys, :key_hash, unique: true
  end
end
