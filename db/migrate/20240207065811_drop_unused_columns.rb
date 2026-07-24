class DropUnusedColumns < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :members, :subscribed_to_newsletter, :boolean
      remove_column :members, :notify_new_posts, :boolean
      remove_column :members, :subscribed_to_mentions, :boolean
    end
  end
end
