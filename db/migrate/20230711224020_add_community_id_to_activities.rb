class AddCommunityIdToActivities < ActiveRecord::Migration[6.1]
  def change
    change_table :activities do |t|
      t.references :community, null: false, foreign_key: { to_table: :communities }, index: true
    end
  end
end
