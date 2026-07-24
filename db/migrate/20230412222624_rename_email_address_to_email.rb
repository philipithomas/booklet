class RenameEmailAddressToEmail < ActiveRecord::Migration[7.0]
  def change
    # Remove old indices
    remove_index :members, name: "index_members_on_email_address"
    remove_index :members, name: "email_unique_per_communitiy"

    # Rename email_address column to email
    rename_column :members, :email_address, :email

    # add back
    add_index :members, [ :email, :community_id ], unique: true, name: "email_unique_per_community"
  end
end
