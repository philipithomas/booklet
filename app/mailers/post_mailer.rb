class PostMailer < ApplicationMailer
  layout "mail/transactional"
  helper :application

  def new_post(post, to_member)
    @community = post.community
    @post = post
    @author = @post.member
    @to_member = to_member
    @email_token = @to_member.generate_email_signed_token
    add_list_unsubscribe_header(:notify_new_posts_email)

    if post.quarantined_at || post.member.quarantined_at
      Rails.logger.info "Suppressed email for Post #{post.id} due to quarantine status. Post quarantined at: #{post.quarantined_at}, Author quarantined at: #{post.member.quarantined_at}"
      return
    end

    if @to_member.push_subscriptions.any? && @to_member.last_seen_at > @post.published_at
      Rails.logger.info "Post #{post.id} already opened by #{@to_member.email} - suppressing email. Last seen: #{@to_member.last_seen_at}, Post published: #{@post.published_at}"
      return
    end

    headers["Message-ID"] = message_id_for_post(@post)

    mail to: to_member.email, subject: post.title, host: @community.host, message_stream: :broadcast do |format|
      format.html { render layout: "mail/prose" }
    end
  end

  def new_reply(reply, to_member)
    @reply = reply
    @post = reply.post
    @community = @post.community
    @author = @reply.member
    @to_member = to_member
    @email_token = @to_member.generate_email_signed_token
    @follow = to_member.follows.find_by(followable: @post)

    if reply.quarantined_at || reply.member.quarantined_at
      Rails.logger.info "Suppressed email for Reply #{reply.id} due to quarantine status."
      return
    end

    if @to_member.push_subscriptions.any? && @to_member.last_seen_at > @reply.created_at
      Rails.logger.info "Reply #{reply.id} already opened by #{@to_member.email} - suppressing email. Last seen: #{@to_member.last_seen_at}, Reply created: #{@reply.created_at}"
      return
    end

    headers["In-Reply-To"] = message_id_for_post(@post)
    headers["References"] = message_id_for_post(@post)

    mail to: to_member.email, subject: I18n.t("mailers.new_reply.subject", title: @post.title),
      host: @community.host do |format|
      format.html { render layout: "mail/prose" }
    end
  end

  def new_post_mention(member, post)
    @community = post.community
    @post = post
    @member = member
    @email_token = @member.generate_email_signed_token
    @author = @post.member
    @follow = member.follows.find_by(followable: @post)

    if post.quarantined_at || post.member.quarantined_at
      Rails.logger.info "Suppressed email for Post #{post.id} due to quarantine status. Post quarantined at: #{post.quarantined_at}, Author quarantined at: #{post.member.quarantined_at}"
      return
    end

    # Check if the member has already seen the post, if so, suppress the email notification
    if @member.push_subscriptions.any? && @member.last_seen_at > @post.published_at
      Rails.logger.info "Suppressed email for Post Mention #{post.id} to Member #{member.id} - post already seen. Last seen: #{@member.last_seen_at}, Post published: #{@post.published_at}"
      return
    end

    headers["Message-ID"] = message_id_for_post(@post)

    mail to: member.email, subject: I18n.t("mailers.new_post_mention.subject", title: @post.title.truncate(20), author_name: @author.name),
      host: @community.host do |format|
      format.html { render template: "post_mailer/new_post", layout: "mail/prose" }
    end
  end

  def new_reply_mention(member, reply)
    @reply = reply
    @post = reply.post
    @community = @post.community
    @member = member
    @author = @reply.member
    @follow = member.follows.find_by(followable: @post)

    if reply.quarantined_at || reply.member.quarantined_at || reply.post.quarantined_at
      Rails.logger.info "Suppressed email for Reply #{reply.id} due to quarantine status"
      return
    end

    # Check if the member has already seen the post, if so, suppress the email notification
    if @member.push_subscriptions.any? && @member.last_seen_at > @reply.created_at
      Rails.logger.info "Suppressed email for Reply Mention #{reply.id} to Member #{member.id} - post already seen. Last seen: #{@member.last_seen_at}, Reply created: #{reply.created_at}"
      return
    end

    headers["In-Reply-To"] = message_id_for_post(@post)
    headers["References"] = message_id_for_post(@post)

    mail to: member.email, subject: I18n.t("mailers.new_reply_mention.subject", title: @post.title.truncate(20), author_name: @author.name),
      host: @community.host do |format|
      format.html { render template: "post_mailer/new_reply", layout: "mail/prose" }
    end
  end

  private

  def message_id_for_post(post)
    "<post-#{post.id}@#{post.community.host}>"
  end
end
