class UniqueSubscriptions < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :push_subscriptions, [ :member_id, :endpoint ], unique: true, algorithm: :concurrently
    add_column :push_subscriptions, :user_agent, :string
  end
end
