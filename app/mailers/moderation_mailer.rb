# app/mailers/moderation_mailer.rb
class ModerationMailer < ApplicationMailer
  layout "mail/transactional"

  def post_quarantined_email(moderation_score)
    @moderation_score = moderation_score
    @post = @moderation_score.moderatable
    @community = @post.community
    mail(to: fetch_recipients, subject: "[Action required] Post hidden for violating community guidelines", bcc: Rails.configuration.support_email, reply_to: Rails.configuration.support_email)
  end

  def reply_quarantined_email(moderation_score)
    @moderation_score = moderation_score
    @reply = @moderation_score.moderatable
    @post = @reply.post
    @community = @post.community
    mail(to: fetch_recipients, subject: "[Action required] Reply hidden for violating community guidelines", bcc: Rails.configuration.support_email, reply_to: Rails.configuration.support_email)
  end

  def member_quarantined_email(moderation_score)
    @moderation_score = moderation_score
    @member = @moderation_score.moderatable
    @community = @member.community
    mail(to: fetch_recipients, subject: "[Action required] Member profile hidden for violating community guidelines", bcc: Rails.configuration.support_email, reply_to: Rails.configuration.support_email)
  end

  private

  def fetch_recipients
    @community.members.active_admins_or_managers.pluck(:email)
  end
end
