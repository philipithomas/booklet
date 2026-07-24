class AddEmailToCommunity < ActiveRecord::Migration[7.0]
  def change
    add_column :communities, :email, :string, null: false, default: ""
  end
end
