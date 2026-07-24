class SearchableContentJob < ApplicationJob
  queue_as :low

  CUSTOM_BACKOFF = lambda do |attempt|
    case attempt
    when 1..5 then 5.minutes
    when 6..25 then 5.minutes
    when 26..49 then 1.hour
    else 1.hour
    end
  end

  retry_on StandardError, wait: CUSTOM_BACKOFF, attempts: 15

  def perform(model_name, model_id)
    return unless ServiceAvailable.openai?
    model = model_name.constantize.find(model_id)
    searchable_content = SearchableContent.find_by(content: model)

    if model.respond_to?(:locked_at) && model.locked_at.present? ||
        model.respond_to?(:quarantined_at) && model.quarantined_at.present? ||
        model.respond_to?(:confirmed_at) && model.confirmed_at.blank? ||
        (model.respond_to?(:published_at) && !model.published?)
      Rails.logger.info "Destroying searchable content for #{model_name} #{model_id}"
      searchable_content&.destroy
      return
    end

    embedding, text = SearchableContentEmbeddingService.new(model).call

    raise StandardError, "SearchableContentEmbeddingService returned null result" if embedding.nil?

    if searchable_content
      searchable_content.update!(embedding: embedding, document: text)
    else
      SearchableContent.create!(
        content: model,
        embedding: embedding,
        document: text,
        community_id: model.community.id,
        content_type: model.class.name,
        content_id: model.id
      )
    end
  end
end
