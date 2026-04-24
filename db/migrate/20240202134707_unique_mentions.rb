class UniqueMentions < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :mentions, [ :source_type, :source_id, :member_id ], unique: true, algorithm: :concurrently
  end
end
