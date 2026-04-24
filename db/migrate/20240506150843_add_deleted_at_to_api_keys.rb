class AddDeletedAtToAPIKeys < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :api_keys, :deleted_at, :datetime
    add_index :api_keys, :deleted_at, algorithm: :concurrently
  end
end
