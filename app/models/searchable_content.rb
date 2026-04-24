# == Schema Information
#
# Table name: searchable_contents
#
#  id           :bigint           not null, primary key
#  content_type :string           not null
#  document     :text
#  embedding    :vector(3072)
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

  has_neighbors :embedding, dimensions: 3072, normalize: true

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
    collection.upsert(build_embedding)
  end

  def destroy_embedding
    collection.delete(ids: [ id.to_s ])
  end

  def neighbors(results: 10, where: {}, where_document: {})
    self.class.find(self.collection.query(
      query_embeddings: [ embedding.embedding ],
      results: results,
      where: where,
      where_document: where_document
    ).map(&:id))
  end

  def self.backfill_documents
    find_each do |searchable_content|
      begin
        content = searchable_content.content
        Rails.logger.info("Processing content #{content.class} #{content.id}")

        text = case content
        when Post
                 "#{content.title}\n#{content.body.to_plain_text}"
        when Member
                 "#{content.name}\n#{content.about.to_plain_text}"
        when Reply
                 content.body.to_plain_text
        else
                 raise ArgumentError, "Unknown content type: #{content.class}"
        end

        Rails.logger.info("Generated document text: #{text[0..100]}...")

        searchable_content.update_column(:document, text) if searchable_content.document != text
        searchable_content.upsert_embedding
      rescue => e
        Rails.logger.error(
          "Error processing content: #{e.message}\n" \
          "Community: #{searchable_content.community.slug} (#{searchable_content.community.name})\n" \
          "Content type: #{content&.class}, Content ID: #{content&.id}\n" \
          "Document text: #{text}"
        )
      end
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
