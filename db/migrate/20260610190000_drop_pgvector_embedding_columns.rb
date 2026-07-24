class DropPgvectorEmbeddingColumns < ActiveRecord::Migration[7.2]
  # Embeddings live in Chroma (see SearchableContent#upsert_embedding); the
  # pgvector copies were never queried, so the extension requirement can go.
  def up
    safety_assured do
      remove_column :searchable_contents, :embedding
      remove_column :searches, :embedding
    end
    disable_extension "vector"
  end

  def down
    enable_extension "vector"
    add_column :searchable_contents, :embedding, :vector, limit: 3072
    add_column :searches, :embedding, :vector, limit: 3072
  end
end
