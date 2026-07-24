class AddEmailVisibilityToCommunity < ActiveRecord::Migration[7.1]
  def change
    add_column :communities, :email_visibility, :string, default: "open", null: false
  end
end
