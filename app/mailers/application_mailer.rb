class ApplicationMailer < ActionMailer::Base
  before_action :add_list_unsubscribe_header, only: [ :mail ]

  def self.deliver_mail(mail)
    if !Rails.env.test? && mail.to.any? { |email| email.end_with?("@example.com") } && mail.to.length == 1
      mail.perform_deliveries = false
      Rails.logger.info "Mail to #{mail.to} dropped by demo interceptor"
    end
    Rails.logger.info "Sending mail with subject: '#{mail.subject}' to: #{mail.to.join(", ")}"
    super(mail)
  end

  rescue_from Postmark::InactiveRecipientError, with: :handle_inactive_recipient

  default reply_to: proc { support_address },
    from: proc { @community ? community_address : booklet_address }

  layout "mailer"

  has_history user: -> { @community&.members&.find_by(email: message.to&.first) },
    extra: -> { { community_id: @community&.id, newsletter_id: @newsletter&.id } }

  track_clicks campaign: false

  utm_params

  protected

  def community_address
    email_domain = Rails.configuration.app_apex_host
    address = Mail::Address.new "#{@community.slug}@#{email_domain}"
    address.display_name = @community.name.dup
    address.format
  end

  def booklet_address
    address = Mail::Address.new Rails.configuration.default_email_from
    address.display_name = I18n.t("booklet")
    address.format
  end

  def set_community(community)
    @community = community
  end

  def support_address
    ActionMailer::Base.email_address_with_name(Rails.configuration.support_email,
      I18n.t("booklet"))
  end

  def handle_inactive_recipient(error)
    Rails.logger.info "Inactive recipient error: #{error}"
  end

  private

  def add_list_unsubscribe_header(email_token_field)
    Rails.logger.info "Adding List-Unsubscribe header for #{@to_member.email} with field #{email_token_field}"
    headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"
    headers["List-Unsubscribe"] = "<#{notification_preference_url(token: @email_token, field: email_token_field, host: @community.host)}>"
  end
end
