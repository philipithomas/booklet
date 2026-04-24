class PublishedReplyNotificationJob < ApplicationJob
  queue_as :critical

  def perform(*replies)
    replies.each do |reply|
      # Skip sending notifications if the post is quarantined
      next if reply.quarantined_at?
      next if reply.member.quarantined_at?
      next if reply.post.member.quarantined_at?
      next if reply.post.quarantined_at?

      # Find active members who are following this post
      followers = Member.active.joins(:follows).where(follows: { followable: reply.post })

      # push
      followers.find_each do |member|
        next if member == reply.member

        if member.notify_mentions_push? && Mention.exists?(member: member, source: reply)
          next
        end

        EnqueueMemberPushNotificationsJob.perform_later(member,
          source: reply,
          title: I18n.t("mailers.new_reply.subject", title: reply.post.title),
          body: reply.body.to_plain_text)
      end

      # emails
      followers.find_each do |member|
        next if member == reply.member

        if member.notify_mentions_email? && Mention.exists?(member: member, source: reply)
          # Skip sending the notification if the member is mentioned in the reply
          next
        end
        PostMailer.new_reply(reply, member).deliver_later(wait: 4.minutes)
      rescue Postmark::InactiveRecipientError
        # TODO: member.unsubscribe!
        Rails.logger.warn "Postmark::InactiveRecipientError for #{member.email}"
      rescue => e
        Sentry.capture_exception(e)
      end
    end
  end
end
