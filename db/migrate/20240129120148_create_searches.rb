class CreateSearches < ActiveRecord::Migration[7.1]
  def change
    create_table :searches do |t|
      t.string :query, null: false
      t.references :member, null: false, foreign_key: true

      t.timestamps
    end

    add_column :searches, :embedding, :vector, limit: 3072
  end
end
