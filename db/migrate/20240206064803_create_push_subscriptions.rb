class CreatePushSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :push_subscriptions do |t|
      t.references :member, null: false, foreign_key: true
      t.string :endpoint
      t.string :p256dh
      t.string :auth
      t.boolean :subscribed, default: true, null: false
      t.references :ahoy_visit, foreign_key: true

      t.timestamps
    end
  end
end
