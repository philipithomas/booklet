require "test_helper"

class Communities::NotificationPreferencesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @community = communities(:lab)
    @member = members(:member)
    host! @community.host
  end

  test "should get show" do
    get notification_preference_path(token: @member.generate_email_signed_token, host: @community.host)
    assert_response :success
  end

  test "should update notification preferences" do
    assert @member.notify_newsletter_email

    patch notification_preference_path(token: @member.generate_email_signed_token), params: {
      member: {
        notify_newsletter_email: "0"
      }
    }
    assert_redirected_to notification_preference_path(token: @member.generate_email_signed_token)
    @member.reload
    assert_not @member.notify_newsletter_email
  end

  test "should list unsubscribe" do
    field = "notify_newsletter_email"
    post notification_preference_url(token: @member.generate_email_signed_token, host: @member.community.host), params: { field: field }
    assert_response :ok
    @member.reload
    assert_not @member.notify_newsletter_email
  end
end
