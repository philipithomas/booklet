class AddNameIndexToMembers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  def change
    add_index :members, "LOWER(name)", name: "index_members_on_lowercase_name", algorithm: :concurrently
  end
end
