class AddSubscribedAtToMember < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :members, :subscribed_at, :datetime, null: true
    add_index :members, :subscribed_at, algorithm: :concurrently
  end
end
