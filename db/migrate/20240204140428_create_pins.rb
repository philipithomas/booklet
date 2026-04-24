class CreatePins < ActiveRecord::Migration[7.1]
  def change
    create_table :pins do |t|
      t.string :code, null: false
      t.references :member, null: false, foreign_key: true
      t.datetime :expires_at, null: false

      t.timestamps
    end
  end
end
