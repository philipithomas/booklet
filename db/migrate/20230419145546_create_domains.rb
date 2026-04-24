class CreateDomains < ActiveRecord::Migration[7.0]
  def change
    create_table :domains do |t|
      t.string "domain", null: false, index: { unique: true }
      t.boolean "verified", default: false
      t.references :community, null: false, foreign_key: true
      t.string "redirect_for_name"
      t.boolean "apex", default: false
      t.timestamps
    end
  end
end
