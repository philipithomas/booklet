class AddOpenSignupsToCommunities < ActiveRecord::Migration[7.0]
  def change
    add_column :communities, :open_signups, :boolean, default: false, null: false
  end
end
