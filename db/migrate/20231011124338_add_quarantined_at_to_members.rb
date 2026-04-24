class AddQuarantinedAtToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :quarantined_at, :datetime
    add_index :members, :quarantined_at
  end
end
