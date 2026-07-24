class AddDocumentToSearchableContent < ActiveRecord::Migration[7.1]
  def change
    add_column :searchable_contents, :document, :text
  end
end
