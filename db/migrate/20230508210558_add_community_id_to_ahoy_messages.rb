class AddCommunityIdToAhoyMessages < ActiveRecord::Migration[7.0]
  def change
    # add
    change_table :ahoy_messages do |t|
      t.references :community, null: true, foreign_key: { to_table: :communities }, index: true
    end
  end
end
