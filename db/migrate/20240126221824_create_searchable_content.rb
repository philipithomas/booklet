class CreateSearchableContent < ActiveRecord::Migration[7.1]
  def change
    create_table :searchable_contents do |t|
      t.references :community, null: false, foreign_key: true
      t.references :content, polymorphic: true, null: false
      t.timestamps
    end

    add_column :searchable_contents, :embedding, :vector, limit: 3072
  end
end
