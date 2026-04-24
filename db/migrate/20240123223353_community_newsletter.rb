class CommunityNewsletter < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    create_join_table :newsletters, :members do |t|
      t.index :newsletter_id
      t.index :member_id
    end

    add_reference :newsletters, :community, null: true, index: { algorithm: :concurrently }

    change_column_null :newsletters, :member_id, true
  end
end
