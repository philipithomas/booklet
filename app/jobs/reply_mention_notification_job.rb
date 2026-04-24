class ReplyMentionNotificationJob < ApplicationJob
  queue_as :critical

  def perform(to_member, reply)
    Rails.logger.info "Performing ReplyMentionNotificationJob for Member ID: #{to_member.id}, Reply ID: #{reply.id}"

    return if reply.quarantined_at?
    return if reply.post.quarantined_at?
    return if reply.member.quarantined_at?

    # Job triggers 1 minute after publish
    # Send push notifications first.
    # Then, trigger email.
    # Email suppresses if member clicked push.
    if to_member.notify_mentions_push
      EnqueueMemberPushNotificationsJob.perform_later(to_member,
        source: reply,
        title: I18n.t("mailers.new_reply_mention.subject", title: reply.post.title.truncate(20), author_name: reply.member.first_name),
        body: reply.body.to_plain_text)
    end

    if to_member.notify_mentions_email
      PostMailer.new_reply_mention(to_member, reply).deliver_later(wait: 4.minutes)
    end
  end
end
