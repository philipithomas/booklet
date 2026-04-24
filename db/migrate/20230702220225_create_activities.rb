class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities do |t|
      t.references :member, null: false, foreign_key: true
      t.references :target, polymorphic: true, null: false
    end
  end
end
