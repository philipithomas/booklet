module Moderatable
  extend ActiveSupport::Concern

  included do
    has_many :moderation_scores, as: :moderatable, dependent: :destroy
    after_create_commit :enqueue_moderation # On update, needs to be manually enqueued

    def moderation_flagged?
      matching_score = moderation_scores.find_by(content_updated_at: updated_at)
      matching_score&.flagged || false
    end
  end

  def quarantine!
    update!(quarantined_at: Time.current)
    if respond_to?(:enqueue_search_embedding)
      enqueue_search_embedding
    end
    self
  end

  def enqueue_moderation
    return unless ServiceAvailable.openai?
    return if saved_change_to_quarantined_at? || quarantined_at?

    Rails.logger.info "Enqueuing moderation job for #{self.class.name} #{id}"
    # Changed fields log
    Rails.logger.info saved_changes

    # Enqueue the job to check the content
    ModerationJob.perform_later(self.class.name, id, updated_at)
  end
end
