class ModerationJob < ApplicationJob
  queue_as :critical

  def perform(model_name, model_id, content_updated_at)
    return unless ServiceAvailable.openai?
    model = model_name.constantize.find(model_id)

    result = ModerationService.new(model.community).call(model)

    raise StandardError, "ModerationService returned null result" if result.nil?

    model.moderation_scores.create!(
      flagged: result["flagged"],
      categories: result["categories"],
      category_scores: result["category_scores"],
      content_updated_at: content_updated_at
    )
  end
end
