class AddSourceToMember < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :members, :source, :string
    add_index :members, :source, algorithm: :concurrently
  end
end
