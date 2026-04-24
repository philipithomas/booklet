class NewsletterMailer < ApplicationMailer
  def new_newsletter(newsletter, member)
    @to_member = member
    @community = newsletter.community
    @newsletter = newsletter
    @email_token = @to_member.generate_email_signed_token
    add_list_unsubscribe_header(:notify_newsletter_email)

    mail to: @to_member.email, subject: @newsletter.subject, host: @community.host, message_stream: :broadcast do |format|
      format.html { render layout: "mail/prose" }
    end
  end
end
