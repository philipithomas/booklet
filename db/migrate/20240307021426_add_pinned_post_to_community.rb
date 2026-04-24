class AddPinnedPostToCommunity < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :communities, :pinned_post, index: { algorithm: :concurrently }
  end
end
