class CreatePeople < ActiveRecord::Migration[7.1]
  def change
    create_table :people do |t|
      t.timestamps
    end

    add_column :members, :person_id, :integer, default: nil
    add_foreign_key :members, :people, column: :person_id, on_delete: :nullify, validate: false
  end
end
