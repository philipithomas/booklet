class SetNotifyNewPostsForAdmins < ActiveRecord::Migration[7.0]
  def change
    Member.where(permission: :admin).update_all(notify_new_posts: true)
  end
end
