class CreateViews < ActiveRecord::Migration[7.1]
  def change
    create_table :views do |t|
      t.references :member, null: false, foreign_key: true
      t.references :viewable, polymorphic: true, null: false, index: { name: "index_views_on_viewable_type_and_viewable_id" }
      t.references :ahoy_visit, foreign_key: true
      t.timestamps
    end
  end
end
