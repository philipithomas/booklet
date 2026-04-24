class CreateVerifications < ActiveRecord::Migration[7.1]
  def change
    create_table :verifications do |t|
      t.timestamps

      t.jsonb :document_address
      t.jsonb :document_dob
      t.jsonb :document_issued_date
      t.jsonb :id_number_dob
      t.jsonb :id_number_first_name
      t.jsonb :id_number_last_name
      t.string :stripe_verification_id
      t.string :document_first_name
      t.string :document_last_name
      t.string :id_number_id_number_type

      # These three should be unique together and are used to link across verifications
      t.string :document_issuing_country, index: true
      t.string :document_number, index: true
      t.string :document_type, index: true

      t.belongs_to :person, index: true, foreign_key: true, null: false
    end

    add_index :verifications, [ :document_issuing_country, :document_number, :document_type ], unique: true, name: "index_verifications_on_document_details"
  end
end
