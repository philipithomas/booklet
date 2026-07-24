class ValidateCreatePeople < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :members, :people
  end
end
