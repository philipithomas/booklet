require "test_helper"

class Members::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @community = communities(:lab)
    host! @community.host
  end

  test "form should not be indexed by search engines" do
    @community.update!(signups: :open)
    get new_member_registration_path
    assert_response :success
    assert_select "meta[name=robots][content=noindex]"
  end

  test "should create a new member within the community" do
    @community.update!(signups: :open)

    assert_difference("Member.count") do
      post member_registration_path, params: {
        member: {
          name: Faker::Name.name,
          email: Faker::Internet.email,
          password: "password123",
          community_id: @community.id
        }
      }
    end
    assert_redirected_to "http://lab.localtest.me/sign-in" # members_registrations_confirmation_pending_path
    follow_redirect!
    assert_response :success
    # assert_select "h1", I18n.translate("devise.confirmations.check_email")
    assert_equal @community, Member.last.community
    assert Member.last.member?
    assert_not Member.last.manager?
    assert_not Member.last.admin?
  end

  test "should not create a new member within the community when signups_open is false" do
    @community.update!(signups: :invite_only)

    assert_no_difference("Member.count") do
      post member_registration_path, params: {
        member: {
          name: Faker::Name.name,
          email: Faker::Internet.email,
          password: "password123",
          community_id: @community.id
        }
      }
    end

    assert_redirected_to posts_path
    assert_equal flash[:alert], "Signups are currently closed for this community."
  end

  test "should get registration form when signups_open is true" do
    @community.update!(signups: :open)
    get new_member_registration_path
    assert_response :success
  end

  test "should not get registration form when signups_open is false" do
    @community.update!(signups: :invite_only)
    get new_member_registration_path
    assert_redirected_to posts_path
    assert_equal flash[:alert], "Signups are currently closed for this community."
  end
end
