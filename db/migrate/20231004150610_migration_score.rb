class MigrationScore < ActiveRecord::Migration[7.0]
  def change
    create_table :moderation_scores do |t|
      t.references :moderatable, polymorphic: true, null: false
      t.boolean :flagged, default: false, null: false, index: true
      t.jsonb :categories, default: {}, index: true
      t.jsonb :category_scores, default: {}
      t.datetime :content_updated_at
      t.timestamps
    end
  end
end
