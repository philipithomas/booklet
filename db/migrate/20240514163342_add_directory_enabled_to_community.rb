class AddDirectoryEnabledToCommunity < ActiveRecord::Migration[7.1]
  def change
    add_column :communities, :directory_enabled, :boolean, default: true, null: false
  end
end
