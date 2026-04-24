class AddQuarantinedAtToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :quarantined_at, :datetime
    add_index :posts, :quarantined_at
  end
end
