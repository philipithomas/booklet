class CreateMentions < ActiveRecord::Migration[7.1]
  def change
    create_table :mentions do |t|
      t.references :source, polymorphic: true, null: false
      t.references :member, null: false, foreign_key: true

      t.timestamps
    end
  end
end
