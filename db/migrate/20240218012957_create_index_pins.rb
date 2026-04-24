class CreateIndexPins < ActiveRecord::Migration[7.1]
  def change
    create_table :index_pins do |t|
      t.string :code, null: false
      t.string :email, null: false, index: true
      t.datetime :expires_at, null: false
      t.timestamps
    end
  end
end
