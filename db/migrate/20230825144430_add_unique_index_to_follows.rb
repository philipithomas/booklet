class AddUniqueIndexToFollows < ActiveRecord::Migration[6.0] # adjust the version as per your Rails version
  def change
    add_index :follows, [ :member_id, :followable_type, :followable_id ], unique: true, name: "index_follows_on_member_and_followable"
  end
end
