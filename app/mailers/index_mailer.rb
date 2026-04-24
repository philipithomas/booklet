class IndexMailer < ApplicationMailer
  layout "mail/transactional"

  def login_pin(index_pin)
    @code = index_pin.code
    mail(to: index_pin.email, subject: I18n.t("mailers.index_login_pin.subject", code: @code))
  end
end
