class AddCommunityNewsletterDays < ActiveRecord::Migration[7.1]
  def change
    add_column :communities, :newsletter_days_bitmask, :integer, default: 127, null: false

    Community.reset_column_information

    # Community.find_each do |community|
    #  community.update_columns(newsletter_days_bitmask: community.default_newsletter_days_bitmask)
    # end
  end
end
