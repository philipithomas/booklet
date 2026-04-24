require "test_helper"

class CustomDeviseMailerTest < ActionMailer::TestCase
  def setup
    I18n.locale = :"en-US"
    @community = communities(:lab)
    @member = members(:member)
    @token = "1234567890"
  end

  test "confirmation_instructions" do
    email = CustomDeviseMailer.confirmation_instructions(@member, @token)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @member.email ], email.to
    assert_equal [ "lab@#{Rails.configuration.app_apex_host}" ], email.from
    assert_equal [ "support@example.com" ], email.reply_to
    assert_equal I18n.t("devise.mailer.confirmation_instructions.subject"), email.subject

    assert email.html_part.body.to_s.include?(I18n.t("devise.mailer.confirmation_instructions.instruction"))
    assert email.html_part.body.to_s.include?(I18n.t("devise.mailer.confirmation_instructions.action"))
    assert email.text_part.body.to_s.include?(I18n.t("devise.mailer.confirmation_instructions.instruction"))
    assert email.text_part.body.to_s.include?(I18n.t("devise.mailer.confirmation_instructions.action"))
  end
end
