require "test_helper"

class Communities::FollowsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @community = communities(:lab)
    host! @community.host
    @member = members(:member)

    @follow = follows(:one)
  end

  test "should get show" do
    get follow_unsubscribe_path(@follow.generate_unsubscribe_signed_id)
    assert_response :success
  end

  test "should get unsubscribe" do
    post follow_confirm_unsubscribe_path(@follow.generate_unsubscribe_signed_id)
    assert_response :created
    assert_raises(ActiveRecord::RecordNotFound) { @follow.reload }
  end

  test "should not show follows from another community" do
    other_follow = follows(:other_follow)
    # Should be redirected to root
    get follow_unsubscribe_path(other_follow.generate_unsubscribe_signed_id)
    assert_redirected_to posts_path
  end
end
