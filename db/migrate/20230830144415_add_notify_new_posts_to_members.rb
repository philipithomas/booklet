class AddNotifyNewPostsToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :notify_new_posts, :boolean, default: false, null: false
  end
end
