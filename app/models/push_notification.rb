# == Schema Information
#
# Table name: push_notifications
#
#  id                   :bigint           not null, primary key
#  body                 :text             not null
#  source_type          :string           not null
#  title                :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  push_subscription_id :bigint           not null
#  source_id            :bigint           not null
#
# Indexes
#
#  index_push_notifications_on_push_subscription_id  (push_subscription_id)
#  index_push_notifications_on_source                (source_type,source_id)
#
# Foreign Keys
#
#  fk_rails_...  (push_subscription_id => push_subscriptions.id)
#
class PushNotification < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true
  validates :source_type, presence: true
  belongs_to :push_subscription
  belongs_to :source, polymorphic: true

  before_create :send_push_notification, unless: -> { Rails.env.test? }

  private

  def member
    push_subscription.member
  end

  def community
    member.community
  end

  def send_push_notification
    self.title = title.truncate(40) if title.present?
    self.body = body.truncate(150) if body.present?

    vapid_details = {
      subject: "mailto:#{community.slug}@#{Rails.configuration.app_apex_host}",
      public_key: community.vapid_public_key,
      private_key: community.vapid_private_key
    }

    message = {
      title: title,
      options: {
        body: body,
        icon: icon_url,
        data: {
          path: path,
          badge: badge
        }
      }
    }

    Rails.logger.info "Sending push notification to PushSubscription #{push_subscription.id} with message: #{message}"

    WebPush.payload_send(
      message: JSON.generate(message),
      endpoint: push_subscription.endpoint,
      p256dh: push_subscription.p256dh,
      auth: push_subscription.auth,
      vapid: vapid_details
    )
  end

  def icon_url
    community.icon.attached? ? community.icon.variant(:thumb).processed.url : nil
  end

  def path
    if source.is_a?(Post)
      Rails.application.routes.url_helpers.post_url(source, host: community.host)
    elsif source.is_a?(Reply)
      Rails.application.routes.url_helpers.post_url(source.post, host: community.host)
    else
      Rails.application.routes.url_helpers.posts_url(host: community.host)
    end
  end

  def badge
    last_seen = member.last_seen_at || Time.current
    push_subscription.push_notifications.where("created_at > ?", last_seen).count + 1
  end
end
