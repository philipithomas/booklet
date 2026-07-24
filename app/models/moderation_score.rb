# == Schema Information
#
# Table name: moderation_scores
#
#  id                 :bigint           not null, primary key
#  categories         :jsonb
#  category_scores    :jsonb
#  content_updated_at :datetime
#  flagged            :boolean          default(FALSE), not null
#  moderatable_type   :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  moderatable_id     :bigint           not null
#
# Indexes
#
#  index_moderation_scores_on_categories   (categories)
#  index_moderation_scores_on_flagged      (flagged)
#  index_moderation_scores_on_moderatable  (moderatable_type,moderatable_id)
class ModerationScore < ApplicationRecord
  extend Memoist

  belongs_to :moderatable, polymorphic: true

  after_create_commit :quarantine_flagged_post, if: -> { flagged && moderatable.is_a?(Post) }
  after_create_commit :quarantine_flagged_reply, if: -> { flagged && moderatable.is_a?(Reply) }
  after_create_commit :quarantine_flagged_member, if: -> { flagged && moderatable.is_a?(Member) }

  def flagged_categories
    violated = []

    categories.each do |category, value|
      violated << category if value
    end

    violated
  end

  memoize :flagged_categories

  private

  def quarantine_flagged_post
    community = moderatable.community
    return unless community.open_ai_content_moderation_enabled

    moderatable.quarantine!

    ModerationMailer.post_quarantined_email(self).deliver_later

    return unless community.open_ai_member_moderation_enabled

    member = moderatable.member
    member.lock_access! unless member.manager_or_admin?
  end

  def quarantine_flagged_reply
    post = moderatable.post
    community = post.community

    return unless community.open_ai_content_moderation_enabled

    moderatable.quarantine!

    ModerationMailer.reply_quarantined_email(self).deliver_later

    return unless community.open_ai_member_moderation_enabled

    member = moderatable.member
    member.lock_access! unless member.manager_or_admin?
  end

  def quarantine_flagged_member
    member = moderatable
    community = member.community

    return unless community.open_ai_content_moderation_enabled

    return if member.manager_or_admin?

    moderatable.quarantine!

    ModerationMailer.member_quarantined_email(self).deliver_later

    return unless community.open_ai_member_moderation_enabled

    member.lock_access!
  end
end
