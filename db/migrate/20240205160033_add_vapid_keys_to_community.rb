class AddVapidKeysToCommunity < ActiveRecord::Migration[7.1]
  def change
    add_column :communities, :vapid_public_key, :string
    add_column :communities, :vapid_private_key, :string
  end
end
