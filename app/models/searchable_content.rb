# == Schema Information
#
# Table name: searchable_contents
#
#  id           :bigint           not null, primary key
#  content_type :string           not null
#  document     :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#  content_id   :bigint           not null
#
# Indexes
#
#  index_searchable_contents_on_community_id  (community_id)
#  index_searchable_contents_on_content       (content_type,content_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#
class SearchableContent < ApplicationRecord
  belongs_to :content, polymorphic: true
  belongs_to :community

  # Embeddings are stored in Chroma, not in Postgres; this attribute carries
  # the freshly generated vector from SearchableContentJob to the after_save
  # upsert.
  attr_accessor :embedding

  after_save :upsert_embedding
  after_destroy :destroy_embedding

  def collection
    Chroma::Resources::Collection.get_or_create(
      "community_#{community_id}",
      {
        community_slug: community.slug
      }
    )
  end

  def delete_collection
    Chroma::Resources::Collection.delete("community_#{community_id}")
  rescue Chroma::InvalidRequestError
    Chroma::Util.log_debug("Collection community_#{community_id} does not exist.")
  end

  def upsert_embedding
    return if embedding.blank?

    collection.upsert(build_embedding)
  end

  def destroy_embedding
    collection.delete(ids: [ id.to_s ])
  end

  def self.backfill_documents
    find_each do |searchable_content|
      SearchableContentJob.perform_later(
        searchable_content.content_type,
        searchable_content.content_id
      )
    end
  end

  private

  def build_embedding
    Chroma::Resources::Embedding.new(
      id: id.to_s,
      document: document,
      embedding: embedding,
      metadata: {
        content_type: content_type,
        content_id: content_id,
        gid: "#{content_type}_#{content_id}"
      }
    )
  end
end
