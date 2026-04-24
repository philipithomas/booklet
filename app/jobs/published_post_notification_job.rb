class PublishedPostNotificationJob < ApplicationJob
  queue_as :critical

  def perform(*posts)
    posts.each do |post|
      # Skip sending notifications if the post is quarantined
      next if post.quarantined_at?
      next if post.member.quarantined_at?

      raise "not published" unless post.published?

      # Job triggers 1 minute after publish
      # Send push notifications first.
      # Then, trigger email.
      # Email suppresses if member clicked push.
      post.community.members.active.where(notify_new_posts_push: true).find_each do |member|
        next if member == post.member

        if member.notify_mentions_push? && Mention.exists?(member: member, source: post)
          # Skip sending the notification if the member is mentioned in the post
          next
        end

        EnqueueMemberPushNotificationsJob.perform_later(member,
          source: post,
          title: post.title,
          body: post.body.to_plain_text)
      end

      post.community.members.active.where(notify_new_posts_email: true).find_each do |member|
        next if member == post.member

        if member.notify_mentions_email? && Mention.exists?(member: member, source: post)
          # Skip sending the notification if the member is mentioned in the post
          next
        end

        PostMailer.new_post(post, member).deliver_later(wait: 4.minutes)
      rescue Postmark::InactiveRecipientError
        # TODO: member.unsubscribe!
        Rails.logger.warn "Postmark::InactiveRecipientError for #{member.email}"
      rescue => e
        Sentry.capture_exception(e)
      end
    end
  end
end
