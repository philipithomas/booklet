class PostMentionNotificationJob < ApplicationJob
  queue_as :critical

  def perform(to_member, post)
    Rails.logger.info "Performing PostMentionNotificationJob for Member ID: #{to_member.id}, Post ID: #{post.id}"

    return if post.quarantined_at?
    return if post.member.quarantined_at?

    # Job triggers 1 minute after publish
    # Send push notifications first.
    # Then, trigger email.
    # Email suppresses if member clicked push.
    if to_member.notify_mentions_push
      EnqueueMemberPushNotificationsJob.perform_later(to_member,
        source: post,
        title: I18n.t("mailers.new_post_mention.subject", title: post.title, author_name: post.member.first_name),
        body: post.body.to_plain_text)
    end

    if to_member.notify_mentions_email
      PostMailer.new_post_mention(to_member, post).deliver_later(wait: 4.minutes)
    end
  end
end
