# == Schema Information
#
# Table name: replies
#
#  id             :bigint           not null, primary key
#  quarantined_at :datetime
#  slug           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  member_id      :bigint           not null
#  post_id        :bigint           not null
#
# Indexes
#
#  index_replies_on_member_id         (member_id)
#  index_replies_on_post_id           (post_id)
#  index_replies_on_post_id_and_slug  (post_id,slug) UNIQUE
#  index_replies_on_quarantined_at    (quarantined_at)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#  fk_rails_...  (post_id => posts.id)
#
class Reply < ApplicationRecord
  extend FriendlyId
  include Moderatable
  include Searchable
  include MentionSourceable

  belongs_to :post, counter_cache: true, touch: true
  belongs_to :member

  has_rich_text :body

  friendly_id :generate_slug, use: :slugged, slug_limit: 20

  validates :body, presence: true
  validate :body_cannot_be_empty

  scope :preloaded, -> { includes(member: [ photo_attachment: :blob ]).with_rich_text_body_and_embeds }

  scope :feed_for, ->(current_member = nil) {
    if current_member
      # Show all non-quarantined replies + the quarantined replies of the current_member
      # Exclude all replies by quarantined members, unless the current_member is the one quarantined
      joins(:member)
        .where(
          "(replies.quarantined_at IS NULL OR (replies.quarantined_at IS NOT NULL AND replies.member_id = :current_member_id)) AND " \
          "(members.quarantined_at IS NULL OR members.id = :current_member_id)",
          current_member_id: current_member.id
        )
    else
      # Show only non-quarantined replies for logged-out users or unspecified members
      # Exclude all replies by quarantined members
      joins(:member)
        .where(
          "replies.quarantined_at IS NULL AND members.quarantined_at IS NULL"
        )
    end.includes(member: [ photo_attachment: :blob ]).with_rich_text_body_and_embeds.order(created_at: :asc)
  }

  after_validation :move_friendly_id_error_to_body

  has_many :activities, as: :target, dependent: :destroy
  has_one :searchable_content, as: :content, dependent: :destroy
  after_save :create_activity

  after_create_commit -> {
    PublishedReplyNotificationJob.set(wait: 1.minutes).perform_later(self)
    auto_follow_parent_post
    broadcast_new_reply
    enqueue_search_embedding
    sync_mentions_if_syncable
    post_in_admin_chat
  }
  after_destroy_commit :broadcast_removed_reply
  after_update_commit :broadcast_updated_reply, :sync_mentions_if_syncable
  audited associated_with: :community

  def community
    post.community
  end

  private

  def post_in_admin_chat
    share_url = community.visibility_private? ? Rails.application.routes.url_helpers.editor_reply_url(self, host: Rails.configuration.editor_host) : Rails.application.routes.url_helpers.post_reply_url(self.post, self.slug, host: community.host)
    PostInAdminChatJob.perform_later("[New reply - #{community.slug} - #{member.email} - #{post.title.truncate(20)}] #{body.to_plain_text.truncate(20)} #{share_url}")
  end

  def broadcast_new_reply
    return if member.quarantined_at?

    broadcast_append_to "#{post.id}_replies", partial: "communities/replies/reply", locals: { reply: self }, target: "replies"

    # Move to top of homepage
    post.broadcast_remove_to(post.community)
    post.broadcast_prepend_later_to(post.community, partial: "components/post/card", locals: { post: post })
  end

  def broadcast_updated_reply
    return if saved_change_to_quarantined_at?

    broadcast_replace_to "#{post.id}_replies", partial: "communities/replies/reply", locals: { reply: self }
  end

  def broadcast_removed_reply
    broadcast_remove_to "#{post.id}_replies"
  end

  def body_cannot_be_empty
    errors.add(:body, "can't be empty") if body.blank?
  end

  def generate_slug
    body.to_plain_text[0..19] # Generate a slug from the first 20 characters of the body
  end

  def should_generate_new_friendly_id?
    slug.blank? || body.changed?
  end

  def move_friendly_id_error_to_body
    errors.add(:body, *errors.delete(:slug)) if errors[:slug].present?
  end

  def create_activity
    return if activities.exists?

    activities.create!(member: member, community: post.community)
  end

  def auto_follow_parent_post
    Follow.find_or_create_by(member: member, followable: post)
  end

  def broadcast_if_quarantine_status_changed
    return unless saved_change_to_quarantined_at?

    return broadcast_remove_to("#{post.id}_replies") if quarantined_at?

    broadcast_append_to "#{post.id}_replies", partial: "communities/replies/reply", locals: { reply: self }, target: "replies"
  end
end
