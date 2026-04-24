class CreateCommunities < ActiveRecord::Migration[7.0]
  def change
    create_table :communities do |t|
      t.string "slug", null: false
      t.string "name", null: false
      t.bigint "ahoy_create_visit_id"
      t.integer "visibility", default: 0, null: false
      t.integer "signups", default: 0, null: false
      t.string "brand_color", null: true
      t.index [ "slug" ], name: "index_communities_on_slug", unique: true

      t.timestamps
    end
  end
end
