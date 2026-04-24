class SubscribedToMentions < ActiveRecord::Migration[7.1]
  def change
    add_column :members, :subscribed_to_mentions, :boolean, default: true, null: false
  end
end
