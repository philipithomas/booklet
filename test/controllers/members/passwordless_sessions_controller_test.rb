require "test_helper"

class Members::PasswordlessSessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    requires_multiuser_mode!
    @community = communities(:lab)
    @member = members(:member)
    host! @community.host
  end

  test "show passwordless session with valid token" do
    token = @member.generate_passwordless_signed_id
    get passwordless_signin_path(token)
    assert_redirected_to posts_path
  end

  test "show passwordless session with invalid token" do
    get passwordless_signin_path("invalid_token")
    assert_redirected_to new_member_session_path
    assert_equal I18n.t("devise.passwordless.sessions.show.alert"), flash[:alert]
  end

  test "show passwordless session with mismatched community" do
    other_community_member = members(:other_member)
    token = other_community_member.generate_passwordless_signed_id
    assert_raises RuntimeError, "Community mismatch" do
      get passwordless_signin_path(token)
    end
  end

  test "show passwordless session with access locked member" do
    @member.lock_access!
    token = @member.generate_passwordless_signed_id
    get passwordless_signin_path(token)
    assert_redirected_to new_member_session_path
  end
end
