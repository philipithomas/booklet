class MakeVerificationsOnDocumentDetailsNoLongerUnique < ActiveRecord::Migration[7.1]
  def change
    remove_index :verifications, name: "index_verifications_on_document_details"
    add_index :verifications, [ :document_issuing_country, :document_number, :document_type ], name: "index_verifications_on_document_details"
  end
end
