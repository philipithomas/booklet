class CreateReplies < ActiveRecord::Migration[7.0]
  def change
    create_table :replies do |t|
      t.references :post, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.string :slug, null: false

      t.timestamps

      t.index [ "post_id", "slug" ], name: "index_replies_on_post_id_and_slug", unique: true
    end
  end
end
