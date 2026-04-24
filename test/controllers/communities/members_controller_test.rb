require "test_helper"

class Communities::MembersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @community = communities(:lab)
    host! @community.host
    @member = members(:member)
    sign_in @member
  end

  test "should get index" do
    get members_path
    assert_response :success
    assert_select "#members>li", count: @community.members.listed.count
  end

  test "should get show" do
    get member_path(@member)
    assert_response :success
    assert_select "h1", @member.name
  end

  test "should get edit" do
    get edit_member_path(@member)
    assert_response :success
  end

  test "should not show members from another community" do
    other_member = members(:other_member)

    assert_raises ActiveRecord::RecordNotFound do
      get member_path(other_member)
    end
  end

  test "should update member" do
    patch member_path(@member), params: { member: { name: "Updated name" } }
    @member.reload
    assert_redirected_to member_path(@member)
    assert_equal "Updated name", @member.name
  end

  test "should not update member with invalid params" do
    patch member_path(@member), params: { member: { name: "" } }
    assert_response :unprocessable_entity
    @member.reload
    assert_not_equal "", @member.name
  end
end
