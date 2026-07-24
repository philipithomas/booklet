class CreateMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :members do |t|
      t.bigint "community_id", null: false, index: true
      t.string "email_address", null: true, index: true
      t.datetime "activated_at", precision: 6, null: true, index: true
      t.datetime "locked_at", precision: 6, null: true, index: true
      t.string "name", default: "", null: false
      t.integer "permission", default: 0, null: false, index: true
      t.string "slug", default: "", null: false
      t.bigint "ahoy_join_visit_id"
      t.index [ "community_id", "slug" ], name: "index_memberships_on_community_id_and_slug", unique: true
      t.index [ "email_address", "community_id" ], name: "email_unique_per_communitiy", unique: true
      t.timestamps
    end
  end
end
