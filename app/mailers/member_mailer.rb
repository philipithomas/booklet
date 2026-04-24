class MemberMailer < ApplicationMailer
  layout "mail/transactional"

  def passwordless_signin_email(member)
    @community = member.community
    @url = passwordless_signin_url(member.generate_passwordless_signed_id, host: @community.host)
    mail(to: member.email, subject: I18n.t("devise.passwordless.mail.subject"))
  end

  def login_pin(member, code)
    @community = member.community
    @code = code
    mail(to: member.email, subject: I18n.t("mailers.login_pin.subject", code: @code, community_name: @community.name))
  end

  def welcome(member)
    @community = member.community
    @member = member
    @url = new_member_session_url(host: @community.host, email_token: @member.generate_email_signed_token)
    mail(to: member.email, subject: "✅ " + I18n.t("mailers.welcome.subject", community_name: @community.name))
  end

  def identity_verified(member)
    @community = member.community
    @url = posts_url(host: @community.host)
    mail(to: member.email, bcc: Rails.configuration.admin_email, subject: I18n.t("mailers.identity_verified.subject", community_name: @community.name))
  end
end
