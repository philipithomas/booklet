class CreateEditors < ActiveRecord::Migration[7.0]
  def change
    create_table :editors do |t|
      t.string :email
      t.string :encrypted_password

      t.timestamps null: false
    end
  end
end
