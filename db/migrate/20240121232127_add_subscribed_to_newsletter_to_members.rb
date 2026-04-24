class AddSubscribedToNewsletterToMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :members, :subscribed_to_newsletter, :boolean, default: true, null: false

    Member.where(newsletter_days_bitmask: 0).find_each do |member|
      member.update!(subscribed_to_newsletter: false)
    end
  end
end
