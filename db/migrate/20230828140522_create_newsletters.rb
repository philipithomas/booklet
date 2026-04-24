class CreateNewsletters < ActiveRecord::Migration[7.0]
  def change
    create_table :newsletters do |t|
      t.references :member, null: false, foreign_key: true
      t.references :previous_newsletter, foreign_key: { to_table: :newsletters }
      t.integer :state, default: 0, null: false

      t.timestamps
    end

    # Create the association tables
    create_table :newsletter_posts do |t|
      t.references :newsletter, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
    end

    create_table :newsletter_existing_posts_with_new_replies do |t|
      t.references :newsletter, null: false, foreign_key: true, index: { name: "index_newsletter_existing_posts_new_replies_on_newsletter_id" }
      t.references :post, null: false, foreign_key: true
    end

    create_table :newsletter_new_members do |t|
      t.references :newsletter, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
    end
  end
end
