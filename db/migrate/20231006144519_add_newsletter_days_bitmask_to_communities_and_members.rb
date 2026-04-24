class AddNewsletterDaysBitmaskToCommunitiesAndMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :communities, :default_newsletter_days_bitmask, :integer, default: 127, null: false
    add_column :members, :newsletter_days_bitmask, :integer

    # Update historical members to have the default newsletter days bitmask
    Member.find_each do |member|
      member.update(newsletter_days_bitmask: member.community.default_newsletter_days_bitmask)
    end
  end
end
