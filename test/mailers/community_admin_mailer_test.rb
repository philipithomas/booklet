require "test_helper"

class CommunityAdminMailerTest < ActionMailer::TestCase
  setup do
    @community = communities(:lab)
    @admins = @community.members.where(permission: :admin)
    @admin_emails = @admins.map(&:email)
  end

  test "domain_verified" do
    requires_multiuser_mode!
    assert @admins.present?, "Community should have admins"
    email = CommunityAdminMailer.domain_verified(@community)

    assert_emails @admins.count do
      email.deliver_now
    end

    assert_equal @admin_emails.sort, email.to.sort
    assert_equal "Your domain is live: lab.localtest.me", email.subject
    assert_equal [ "support@example.com" ], email.bcc
    assert_equal [ "support@example.com" ], email.reply_to

    assert_includes email.html_part.body.to_s, I18n.t("emails.community_admin_mailer.domain_verified.line_1")
    assert_includes email.html_part.body.to_s, I18n.t("emails.community_admin_mailer.domain_verified.line_2")
    assert_includes email.html_part.body.to_s, I18n.t("emails.community_admin_mailer.domain_verified.button_label", host: @community.host)
  end

  test "no admins" do
    @community.members.where(permission: :admin).delete_all
    assert_raises(RuntimeError, "No admins for #{@community.name}") do
      CommunityAdminMailer.domain_verified(@community).deliver_now
    end
  end
end
