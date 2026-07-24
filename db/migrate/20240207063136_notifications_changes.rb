class NotificationsChanges < ActiveRecord::Migration[7.1]
  def change
    add_column :members, :notify_new_posts_email, :boolean, default: false, null: false
    add_column :members, :notify_new_posts_push, :boolean, default: false, null: false
    add_column :members, :notify_mentions_email, :boolean, default: true, null: false
    add_column :members, :notify_mentions_push, :boolean, default: true, null: false
    add_column :members, :notify_newsletter_email, :boolean, default: true, null: false
    add_column :members, :notify_newsletter_push, :boolean, default: true, null: false

    Member.reset_column_information

    Member.find_each do |member|
      Member.where(id: member.id).update_all(
        notify_new_posts_email: member.notify_new_posts,
        notify_new_posts_push: member.notify_new_posts,
        notify_mentions_email: member.subscribed_to_mentions,
        notify_mentions_push: member.subscribed_to_mentions,
        notify_newsletter_email: member.subscribed_to_newsletter,
        notify_newsletter_push: member.subscribed_to_newsletter
      )
    end
  end
end
