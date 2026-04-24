# == Schema Information
#
# Table name: searches
#
#  id         :bigint           not null, primary key
#  embedding  :vector(3072)
#  query      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  member_id  :bigint           not null
#
# Indexes
#
#  index_searches_on_member_id  (member_id)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#
class Search < ApplicationRecord
  belongs_to :member
  validates :query, presence: true
  has_neighbors :embedding, dimensions: 3072, normalize: true

  def embed
    update!(embedding: SearchEmbeddingService.new(self).call)
    self
  end

  def chroma_query(results: 10, where: {})
    community_id = member.community_id
    collection = Chroma::Resources::Collection.get_or_create(
      "community_#{community_id}",
      {
        community_slug: member.community.slug
      }
    )
    id = self.id
    embedding = self.embedding

    results = collection.query(
      query_embeddings: [ embedding ],
      where: where,
      results: results,
    )
    # debugger

    SearchableContent.find(results.map(&:id))
  end
end
