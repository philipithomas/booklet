class CreateFollows < ActiveRecord::Migration[7.0]
  def change
    create_table :follows do |t|
      t.references :member, null: false, foreign_key: true
      t.references :followable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
