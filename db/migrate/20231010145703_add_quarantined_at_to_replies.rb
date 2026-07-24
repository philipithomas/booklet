class AddQuarantinedAtToReplies < ActiveRecord::Migration[7.0]
  def change
    add_column :replies, :quarantined_at, :datetime
    add_index :replies, :quarantined_at
  end
end
