module Searchable
  extend ActiveSupport::Concern

  def enqueue_search_embedding
    return unless ServiceAvailable.openai?
    SearchableContentJob.perform_later(self.class.name, id)
  end
end
