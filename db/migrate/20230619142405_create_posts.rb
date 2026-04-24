class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.references :community, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.string :slug, null: false
      t.timestamps
      t.index [ "community_id", "slug" ], name: "index_posts_on_community_id_and_slug", unique: true
    end
  end
end
