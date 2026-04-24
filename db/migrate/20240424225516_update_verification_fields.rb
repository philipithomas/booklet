class UpdateVerificationFields < ActiveRecord::Migration[7.1]
  def change
    remove_column :verifications, :id_number_dob
    remove_column :verifications, :id_number_first_name
    remove_column :verifications, :id_number_id_number_type
    remove_column :verifications, :id_number_last_name
    add_column :verifications, :document_expiration_date, :jsonb
  end
end
