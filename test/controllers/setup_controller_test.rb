require "test_helper"

class SetupControllerTest < ActionDispatch::IntegrationTest
  test "new community form should be available" do
    get new_community_url(host: "new.localtest.me")
    assert_response :success
    assert @response.body.include?(I18n.t("setup.new.title"))
    assert_select "title", I18n.t("setup.new.title")
  end

  test "should create community" do
    assert_difference("Community.count") do
      post new_community_url(host: "new.localtest.me"), params: {
        community: {
          name: "New Community",
          email: "me@gmail.com"
        }
      }
    end
    assert_response :success
  end

  test "new page should have a noindex tag" do
    get new_community_url(host: "new.localtest.me")
    assert_response :success
    assert @response.body.include?("noindex")
  end
end
