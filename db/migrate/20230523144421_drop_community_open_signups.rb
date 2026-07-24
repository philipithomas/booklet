class DropCommunityOpenSignups < ActiveRecord::Migration[7.0]
  def change
    remove_column :communities, :open_signups, :boolean, null: false, default: false
  end
end
