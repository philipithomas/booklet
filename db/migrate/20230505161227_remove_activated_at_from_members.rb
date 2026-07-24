class RemoveActivatedAtFromMembers < ActiveRecord::Migration[7.0]
  def change
    remove_column :members, :activated_at, :datetime
  end
end
