module MentionSourceable
  extend ActiveSupport::Concern

  included do
    has_many :mentions, as: :source, dependent: :destroy
  end

  def sync_mentions_if_syncable
    sync_mentions if mentions_syncable?
  end

  def mentions_syncable?
    !respond_to?(:published_at) || (respond_to?(:published_at) && published_at?)
  end

  def sync_mentions
    Rails.logger.debug "Syncing mentions for #{self.class.name} with ID: #{id}"

    current_mentioned_members = mentioned_members
    Rails.logger.debug "Current mentioned members: #{current_mentioned_members.map(&:id)}"

    existing_mentions = mentions.map(&:member)
    Rails.logger.debug "Existing mentions: #{existing_mentions.map(&:id)}"

    # Members that have been mentioned and do not already have a mention record
    new_mentions = current_mentioned_members - existing_mentions
    Rails.logger.debug "Creating new mentions for members: #{new_mentions.map(&:id)}"
    new_mentions.each do |member|
      mentions.create(member: member)
      Rails.logger.debug "Created mention for member with ID: #{member.id}"
    end

    # Members that are no longer mentioned and need their mention record removed
    mentions_to_remove = existing_mentions - current_mentioned_members
    Rails.logger.debug "Removing mentions for members: #{mentions_to_remove.map(&:id)}"
    mentions_to_remove.each do |member|
      mentions.where(member: member).destroy_all
      Rails.logger.debug "Removed mention for member with ID: #{member.id}"
    end
  end

  def mentioned_members
    if body&.body
      body.body.attachables.grep(Member).uniq
    else
      []
    end
  end
end
