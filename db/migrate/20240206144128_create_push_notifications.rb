class CreatePushNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :push_notifications do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.references :source, polymorphic: true, null: false
      t.belongs_to :push_subscription, null: false, foreign_key: true

      t.timestamps
    end
  end
end
