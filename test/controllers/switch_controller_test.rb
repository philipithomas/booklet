require "test_helper"

class SwitchControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    requires_multiuser_mode!
    @member = members(:member)
    @other_member = members(:after_member)
    @community = communities(:lab)
    @other_community = communities(:after_lab)
    sign_in @member
  end

  test "should get index if member is signed in and confirmed" do
    get switch_index_url
    assert_response :success
  end

  test "should not get index if member is not signed in" do
    sign_out @member
    assert_raises(ActionController::RoutingError) do
      get switch_index_url
    end
  end

  test "should redirect to sign in url on show if member is signed in and confirmed" do
    get switch_path(@other_community.slug)
    assert_response :see_other
    assert_redirected_to %r{\Ahttp://#{Regexp.escape(@other_member.community.host)}}
  end

  test "should not get show if member is not signed in" do
    sign_out @member
    assert_raises(ActionController::RoutingError) do
      get switch_url(@other_community.slug)
    end
  end
end
