class AddPublishedAtToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :published_at, :datetime, null: true, default: nil, index: true
  end
end
