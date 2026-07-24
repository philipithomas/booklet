class AddNewsletterIdToAhoyMessages < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  def change
    add_column :ahoy_messages, :newsletter_id, :bigint, null: true
    add_index :ahoy_messages, :newsletter_id, algorithm: :concurrently
    add_foreign_key :ahoy_messages, :newsletters, column: :newsletter_id, validate: false
  end
end
