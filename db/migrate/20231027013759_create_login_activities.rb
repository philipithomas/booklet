class CreateLoginActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :login_activities do |t|
      t.string :scope
      t.string :strategy
      t.string :identity, index: true
      t.boolean :success, default: false, null: false
      t.string :failure_reason
      t.references :user, polymorphic: true
      t.string :context
      t.string :ip, index: true
      t.text :user_agent
      t.text :referrer
      t.string :city
      t.string :region
      t.string :country
      t.float :latitude
      t.float :longitude
      t.datetime :created_at
      t.references :community, foreign_key: true, index: true, null: true
      t.string :host
    end
  end
end
