# == Schema Information
#
# Table name: newsletters
#
#  id                     :bigint           not null, primary key
#  state                  :integer          default("pending"), not null
#  subject                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  community_id           :bigint
#  member_id              :bigint
#  previous_newsletter_id :bigint
#
# Indexes
#
#  index_newsletters_on_community_id            (community_id)
#  index_newsletters_on_member_id               (member_id)
#  index_newsletters_on_previous_newsletter_id  (previous_newsletter_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (member_id => members.id)
#  fk_rails_...  (previous_newsletter_id => newsletters.id)
#
class Newsletter < ApplicationRecord
  extend Memoist

  belongs_to :community
  has_and_belongs_to_many :members

  enum state: {
    pending: 0,
    success: 1,
    skip_no_content: 2,
    error: 3
  }

  belongs_to :previous_newsletter, class_name: "Newsletter", optional: true
  has_many :newsletter_posts, dependent: :destroy
  has_many :new_posts, through: :newsletter_posts, source: :post
  has_many :newsletter_existing_post_with_new_replies, dependent: :destroy
  has_many :existing_post_with_new_replies, through: :newsletter_existing_post_with_new_replies, source: :post
  has_many :newsletter_new_members, dependent: :destroy
  has_many :new_members, through: :newsletter_new_members, source: :member

  after_create :set_content_and_state

  def set_content_and_state
    raise "Newsletter must be pending" unless pending?

    # Set previous newsletter if not the first one
    self.previous_newsletter = community.newsletters.where(state: :success).where.not(id: id).last

    end_time = created_at
    start_time = previous_newsletter&.created_at || community.created_at
    one_week_ago = end_time - 1.week

    # Take the maximum of start_time and one_week_ago
    time_threshold = [ start_time, one_week_ago ].max

    # Fetch new posts in the community
    self.new_posts = Post.published.where(
      published_at: time_threshold..end_time,
      community_id: community.id,
      quarantined_at: nil # Exclude quarantined posts,
    )

    # Fetch active members in the community confirmed in the time window and not the target member
    if community.directory_enabled?
      self.new_members = community.members.active.where(
        confirmed_at: time_threshold..end_time,
        quarantined_at: nil # Exclude quarantined members
      )
    end

    # Fetch existing posts with new replies from other members
    new_post_ids = new_posts.pluck(:id)

    # Fetch existing posts with new replies from other members excluding the new_posts
    self.existing_post_with_new_replies = Post.joins(:replies).where(
      replies: {
        created_at: time_threshold..end_time,
        quarantined_at: nil # Exclude quarantined replies
      },
      community_id: community.id,
      quarantined_at: nil # Exclude quarantined posts
    ).where.not(id: new_post_ids).distinct

    # Set subject
    if new_posts.any? || (existing_post_with_new_replies.any?)
      save!
      self.subject = NewsletterSubjectSummarizationService.new(self).call

      success!
    else
      skip_no_content!
    end
  end

  def new_replies_summary(post)
    NewRepliesSummarizationService.new(self, post).call
  end

  def new_post_summary(post)
    NewPostSummarizationService.new(self, post).call
  end

  memoize :new_replies_summary, :new_post_summary

  audited associated_with: :community

  after_commit :enqueue_notifications, if: -> { saved_change_to_state? && success? }

  private

  def enqueue_notifications
    community.members.active_and_subscribed.where(notify_newsletter_email: true).find_each do |member|
      NewsletterMailer.new_newsletter(self, member).deliver_later
    end

    community.members.active_and_subscribed.where(notify_newsletter_push: true).find_each do |member|
      EnqueueMemberPushNotificationsJob.perform_later(member,
        source: self,
        title: subject,
        body: [
          ("#{new_posts.count} new #{"post".pluralize(new_posts.count)}" if new_posts.count > 0),
          ("#{existing_post_with_new_replies.count} active #{"discussion".pluralize(existing_post_with_new_replies.count)}" if existing_post_with_new_replies.count > 0),
          ("#{community.members.active.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count} new #{"member".pluralize(community.members.active.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count)}" if community.members.active.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count > 0)
        ].compact.join(", "))
    end
  end
end
