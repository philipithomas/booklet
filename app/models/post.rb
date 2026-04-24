# == Schema Information
#
# Table name: posts
#
#  id             :bigint           not null, primary key
#  prompt         :string
#  published_at   :datetime
#  quarantined_at :datetime
#  replies_count  :integer          default(0), not null
#  slug           :string           not null
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  community_id   :bigint           not null
#  member_id      :bigint           not null
#
# Indexes
#
#  index_posts_on_community_id           (community_id)
#  index_posts_on_community_id_and_slug  (community_id,slug) UNIQUE
#  index_posts_on_member_id              (member_id)
#  index_posts_on_quarantined_at         (quarantined_at)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (member_id => members.id)
#
class Post < ApplicationRecord
  extend FriendlyId
  include Moderatable
  include Searchable
  include MentionSourceable
  include Promptable

  belongs_to :community
  belongs_to :member

  friendly_id :title, use: %i[slugged history scoped], scope: :community, slug_limit: 50
  validates :title, presence: true, length: { maximum: 255 }
  validate :body_cannot_be_empty

  has_one :pinning_community, class_name: "Community", foreign_key: "pinned_post_id", inverse_of: :posts

  audited associated_with: :community

  has_rich_text :body

  after_validation :move_friendly_id_error_to_title

  scope :preloaded, -> { includes(member: [ photo_attachment: [ blob: [ variant_records: { image_attachment: :blob } ] ] ]).with_rich_text_body_and_embeds }
  scope :feed_for, ->(current_member = nil, community = nil) {
    # We will use a subquery to find the most recent reply for each post.
    recent_reply_subquery = Reply.select("MAX(created_at)").where("replies.post_id = posts.id")

    base_query = if current_member
      # Join the members table
      joins(:member).where(
        # Show all non-quarantined posts + the quarantined posts of the current_member
        "(posts.quarantined_at IS NULL AND members.quarantined_at IS NULL) OR
     (posts.quarantined_at IS NOT NULL AND posts.member_id = ?) OR
     (members.quarantined_at IS NOT NULL AND posts.member_id = ?)",
        current_member.id, current_member.id
      )
    else
      # Show only non-quarantined posts for logged-out users or unspecified members
      joins(:member).where(posts: { quarantined_at: nil }, members: { quarantined_at: nil })
    end

    # Exclude the pinned post if it exists
    base_query = base_query.where.not(id: community.pinned_post_id) if community&.pinned_post_id

    base_query.where.not(published_at: nil)
      # Here's the ordering: we use COALESCE to first try to order by the most recent reply's created_at
      # If that's null (i.e., there's no reply), it falls back to ordering by the post's published_at
      .order(Arel.sql("COALESCE((#{recent_reply_subquery.to_sql}), posts.published_at) DESC"))
      .includes(member: [ photo_attachment: [ blob: [ variant_records: { image_attachment: :blob } ] ] ])
  }
  scope :published, -> { where.not(published_at: nil).order(published_at: :desc) }
  scope :drafts, ->(member) { where(published_at: nil, member_id: member.id).order(updated_at: :desc) }
  has_many :activities, as: :target, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :follows, as: :followable, dependent: :destroy
  has_many :newsletter_posts, dependent: :destroy
  has_many :newsletter_existing_post_with_new_replies, dependent: :destroy
  has_many :views, as: :viewable, dependent: :destroy
  has_one :searchable_content, as: :content, dependent: :destroy

  after_save :create_activity_if_published
  after_create_commit :auto_follow_for_creator, :enqueue_search_embedding, :sync_mentions_if_syncable
  after_update :broadcast_if_quarantine_status_changed
  after_commit :broadcast_updates, on: :update, if: :published?
  after_commit :broadcast_destroyed, on: :destroy
  after_update_commit :sync_mentions_if_syncable

  def publish!
    update(published_at: Time.zone.now)
    PublishedPostNotificationJob.set(wait: 1.minute).perform_later(self)
    enqueue_moderation
    enqueue_search_embedding
    post_in_admin_chat
    broadcast_created unless member.quarantined_at?
    self
  end

  def published?
    published_at? && published_at <= Time.zone.now
  end

  private

  def post_in_admin_chat
    share_url = community.visibility_private? ? Rails.application.routes.url_helpers.editor_post_url(self, host: Rails.configuration.editor_host) : Rails.application.routes.url_helpers.post_url(self, host: community.host)
    PostInAdminChatJob.perform_later("[New post - #{community.slug} - #{member.email}] #{title} #{share_url}")
  end

  def broadcast_created
    broadcast_prepend_later_to(community, partial: "components/post/card", locals: { post: self })
  end

  def broadcast_updates
    return if saved_change_to_quarantined_at?

    broadcast_replace_later(partial: "components/post/post", locals: { post: self })
    broadcast_replace_later_to(community, partial: "components/post/card", locals: { post: self })
  end

  def broadcast_destroyed
    broadcast_remove_to(community)
  end

  def published_post_has_published_at_timestamp
    errors.add(:post, "published_at required in accepted state") unless published_at?
  end

  def move_friendly_id_error_to_title
    errors.add :title, *errors.delete(:friendly_id) if errors[:friendly_id].present?
  end

  def body_cannot_be_empty
    errors.add(:body, "can't be empty") if body.blank?
  end

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

  def create_activity_if_published
    return if activities.exists?
    return unless published_at?

    activities.create!(member: member, community: community)
  end

  def auto_follow_for_creator
    follows.create(member: member)
  end

  def broadcast_if_quarantine_status_changed
    return unless saved_change_to_quarantined_at?

    return broadcast_remove_to(community) if quarantined_at?

    broadcast_prepend_later_to(community, partial: "components/post/card",
      locals: { post: self })
  end
end
