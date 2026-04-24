require "test_helper"

class Members::SessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @community = communities(:lab)
    @member = members(:member)
    host! @community.host
  end

  test "sign in form" do
    get new_member_session_path
    assert_response :success
  end

  test "request one-time password" do
    post member_session_path, params: { member: { email: @member.email, community_id: @community.id.to_s } }
    assert_response :success
  end

  test "sign in with one-time password" do
    pin = @member.send_login_pin
    post member_session_path, params: { member: { email: @member.email, password: pin.code, community_id: @community.id.to_s } }
    assert_redirected_to posts_path
  end

  test "sign in with invalid one-time password" do
    post member_session_path, params: { member: { email: @member.email, password: "wrong_otp", community_id: @community.id.to_s } }
    assert_response :unauthorized
  end

  test "sign in with expired one-time password" do
    pin = @member.pins.create(code: SecureRandom.random_number(100000..999999), expires_at: 10.minutes.ago)
    post member_session_path, params: { member: { email: @member.email, password: pin.code, community_id: @community.id.to_s } }
    assert_response :unauthorized
  end

  test "sign in with invalid community id and one-time password" do
    assert_raises ActiveRecord::RecordNotFound do
      post member_session_path, params: { member: { email: @member.email, password: "123456", community_id: communities(:other).id.to_s } }
    end
  end

  test "sign in with invalid email and one-time password" do
    post member_session_path, params: { member: { email: "notme@gmail.com.com", password: "123456", community_id: @community.id.to_s } }
    assert_response :see_other, "http://lab.localtest.me:3000/sign-in"
  end

  test "sign in with unconfirmed member and one-time password" do
    @member.update(confirmed_at: nil)
    pin = @member.send_login_pin
    post member_session_path, params: { member: { email: @member.email, password: pin.code, community_id: @community.id.to_s } }
    assert_redirected_to "http://lab.localtest.me/"
    @member.reload
    assert @member.confirmed?
  end

  test "sign in with access locked member and one-time password" do
    @member.lock_access!
    pin = @member.send_login_pin
    post member_session_path, params: { member: { email: @member.email, password: pin.code, community_id: @community.id.to_s } }
    assert_redirected_to "http://lab.localtest.me/sign-in"
  end
end
